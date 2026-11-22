variable "resource_tag_key" {
  default     = ""
  type        = string
  description = "Namespaced tag key (<project-id>/<short-name>, for example \"my-project/plane\"). If set, every role of the bootstrap GSA gets an IAM condition, and the GSA can change only resources that have this tag. Requires streamnative_org_id."
  validation {
    condition     = var.resource_tag_key == "" || can(regex("^[^/]+/[^/]+$", var.resource_tag_key))
    error_message = "The resource_tag_key must have the form <parent>/<short-name>."
  }
}

variable "resource_tag_value" {
  default     = "dp"
  type        = string
  description = "Short name of the tag value that marks the resources that the bootstrap GSA can change. Used only when resource_tag_key is set."
}

variable "create_resource_tag" {
  default     = false
  type        = bool
  description = "If true, create the tag key and the tag value in the project. The namespace of resource_tag_key must then be the project ID."
}

variable "grant_tag_user_on_value" {
  default     = false
  type        = bool
  description = "If true, grant roles/resourcemanager.tagUser to the bootstrap GSA on the tag value only (not on the key or the project), so that the GSA can attach the tag at create time."
}

variable "tag_mode_grantable_roles" {
  default = [
    "roles/artifactregistry.reader",
    "roles/autoscaling.metricsWriter",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ]
  type        = list(string)
  description = "In tag mode, the only roles that the bootstrap GSA can grant with roles/resourcemanager.projectIamAdmin. The GSA can grant these roles to any member, itself included, so the list must not hold admin, IAM, tag or basic roles."
  validation {
    condition = alltrue([
      for r in var.tag_mode_grantable_roles :
      !can(regex("(?i)(owner|editor|admin|iam\\.|resourcemanager\\.|serviceaccount|workloadidentity|tag|privilegedaccessmanager)", r))
    ])
    error_message = "The tag_mode_grantable_roles must not contain basic, admin, IAM, service account, resourcemanager, tag or PAM roles."
  }
}

locals {
  tag_mode               = var.resource_tag_key != ""
  project_iam_admin_role = "roles/resourcemanager.projectIamAdmin"

  default_roles = [
    "roles/editor",
    "roles/cloudkms.admin",
    "roles/compute.admin",
    "roles/compute.loadBalancerAdmin",
    "roles/compute.networkAdmin",
    "roles/container.admin",
    "roles/dns.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin"
  ]

  # roles/editor cannot have a condition. iam.serviceAccountAdmin and
  # iam.workloadIdentityPoolAdmin are dropped: a create call is checked against
  # the project's tags, so a tag condition refuses SA and pool creation, and
  # serviceAccountAdmin on a tagged SA can grant token creation on that SA.
  tag_mode_default_roles = [
    "roles/cloudkms.admin",
    "roles/compute.admin",
    "roles/compute.loadBalancerAdmin",
    "roles/compute.networkAdmin",
    "roles/container.admin",
    "roles/dns.admin",
    "roles/storage.admin",
    "roles/resourcemanager.projectIamAdmin"
  ]

  roles = var.roles != null ? var.roles : (local.tag_mode ? local.tag_mode_default_roles : local.default_roles)

  # Roles that do not accept conditions, that can grant impersonation, or that
  # let the GSA attach the tag to control plane resources. Custom roles are
  # refused because the module cannot check their permissions.
  # projectIamAdmin gets the grant limit when every role is limited, or when it
  # is listed in tag_condition_roles.
  grant_limit_project_iam_admin = var.tag_condition_roles == null || contains(coalesce(var.tag_condition_roles, []), local.project_iam_admin_role)

  # Roles that get the tag condition. Other roles (when tag_condition_roles is
  # set) are bound with no condition.
  tag_conditioned_roles = [
    for r in local.roles : r
    if r != local.project_iam_admin_role && (var.tag_condition_roles == null || contains(coalesce(var.tag_condition_roles, []), r))
  ]

  # Basic roles carry container.* and cannot take a condition, and tag roles let
  # the GSA tag control plane resources: refused in tag mode. iam.* and custom
  # roles are refused only when they get the tag condition (tags cannot limit
  # iam.* roles, and the module cannot check custom roles).
  tag_mode_forbidden_roles = [
    for r in local.roles : r
    if contains(["roles/owner", "roles/editor", "roles/viewer"], r) || can(regex("(?i)^roles/resourcemanager\\.tag", r)) || (contains(local.tag_conditioned_roles, r) && (can(regex("(?i)^roles/iam\\.", r)) || !can(regex("^roles/", r))))
  ]

  resource_tag_condition    = "resource.matchTag('${var.resource_tag_key}', '${var.resource_tag_value}')"
  grantable_roles_condition = "api.getAttribute('iam.googleapis.com/modifiedGrantsByRole', []).hasOnly([${join(", ", [for r in var.tag_mode_grantable_roles : "'${r}'"])}])"
}

resource "google_tags_tag_key" "plane" {
  count       = local.tag_mode && var.create_resource_tag ? 1 : 0
  parent      = "projects/${var.project}"
  short_name  = split("/", var.resource_tag_key)[1]
  description = "Marks resources that the StreamNative bootstrap GSA can manage."
  depends_on  = [google_project_service.gcp_apis]

  lifecycle {
    precondition {
      condition     = split("/", var.resource_tag_key)[0] == var.project
      error_message = "If create_resource_tag is true, the namespace of resource_tag_key must be the project ID."
    }
  }
}

resource "google_tags_tag_value" "plane" {
  count       = length(google_tags_tag_key.plane)
  parent      = google_tags_tag_key.plane[0].id
  short_name  = var.resource_tag_value
  description = "Resource that the StreamNative bootstrap GSA can manage."
}

data "google_tags_tag_key" "plane" {
  count      = local.tag_mode && !var.create_resource_tag && var.grant_tag_user_on_value ? 1 : 0
  parent     = "projects/${split("/", var.resource_tag_key)[0]}"
  short_name = split("/", var.resource_tag_key)[1]
}

data "google_tags_tag_value" "plane" {
  count      = length(data.google_tags_tag_key.plane)
  parent     = data.google_tags_tag_key.plane[0].id
  short_name = var.resource_tag_value
}

locals {
  tag_value_id = local.tag_mode ? one(concat(google_tags_tag_value.plane[*].id, data.google_tags_tag_value.plane[*].id)) : null
}

resource "google_tags_tag_value_iam_member" "sn_bootstrap_tag_user" {
  count     = local.tag_mode && var.grant_tag_user_on_value && local.is_impersonation_enabled ? 1 : 0
  tag_value = local.tag_value_id
  role      = "roles/resourcemanager.tagUser"
  member    = format("serviceAccount:%s", google_service_account.sn_bootstrap[0].email)
}

output "resource_tag" {
  value = local.tag_mode ? {
    key                = var.resource_tag_key
    value              = var.resource_tag_value
    tag_value_id       = local.tag_value_id
    condition          = local.resource_tag_condition
    grantable_roles    = var.tag_mode_grantable_roles
    project_iam_admin  = local.grantable_roles_condition
    bootstrap_gsa_role = local.streamnative_bootstrap_roles
  } : null
  description = "Tag mode settings of the bootstrap GSA (null when tag mode is off)."

  precondition {
    condition     = !local.tag_mode || local.is_impersonation_enabled
    error_message = "The resource_tag_key requires streamnative_org_id (tag conditions apply to the bootstrap GSA only)."
  }
}

variable "tag_condition_roles" {
  default     = null
  type        = list(string)
  description = "In tag mode, the roles that get the tag condition. null = every role (projectIamAdmin gets the grant limit instead). For example [\"roles/container.admin\"] limits only direct GKE access to tagged clusters and keeps the other roles, projectIamAdmin included, with no condition. Roles with no condition can still give indirect access (projectIamAdmin, iam.serviceAccountAdmin)."
}

variable "tag_mode_extra_bindings" {
  default     = []
  type        = list(object({ role = string, title = string, expression = string }))
  description = "In tag mode, more roles for the bootstrap GSA for work that a tag condition cannot allow, for example creating service accounts (a create call is checked against the project's tags). Set expression to \"\" for no condition; only roles/iam.serviceAccountCreator can have no condition."
  validation {
    condition = alltrue([
      for b in var.tag_mode_extra_bindings :
      !contains(["roles/owner", "roles/editor", "roles/viewer"], b.role) && !can(regex("(?i)^roles/resourcemanager\\.tag", b.role)) && (b.expression != "" || b.role == "roles/iam.serviceAccountCreator")
    ])
    error_message = "tag_mode_extra_bindings must not hold basic or tag roles, and every role except roles/iam.serviceAccountCreator needs a condition expression."
  }
}

# Extra roles of the bootstrap GSA in tag mode (see tag_mode_extra_bindings).
resource "google_project_iam_member" "sn_bootstrap_extra" {
  count   = local.tag_mode && local.is_impersonation_enabled ? length(var.tag_mode_extra_bindings) : 0
  project = var.project
  role    = var.tag_mode_extra_bindings[count.index].role
  member  = format("serviceAccount:%s", google_service_account.sn_bootstrap[0].email)

  dynamic "condition" {
    for_each = var.tag_mode_extra_bindings[count.index].expression != "" ? [var.tag_mode_extra_bindings[count.index]] : []
    content {
      title      = condition.value.title
      expression = condition.value.expression
    }
  }
}
