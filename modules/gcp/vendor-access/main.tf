locals {
  google_services = concat([
    "autoscaling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "domains.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "networkmanagement.googleapis.com",
    "servicedirectory.googleapis.com",
    "servicemanagement.googleapis.com",
    "siteverification.googleapis.com",
  ], var.extra_google_services)
}

resource "google_project_service" "gcp_apis" {
  count              = length(local.google_services)
  project            = var.project
  disable_on_destroy = false
  service            = local.google_services[count.index]
}

locals {
  is_impersonation_enabled = var.streamnative_org_id != ""
  streamnative_gsa         = concat(var.streamnative_vendor_access_gsa, var.streamnative_support_access_gsa)
}

# Grant permissions directly to the StreamNative Cloud service account
locals {
  iam_bindings = local.is_impersonation_enabled ? [] : flatten([
    for role in local.roles : [
      for gsa in local.streamnative_gsa : {
        role : role,
        member : format("serviceAccount:%s", gsa),
      }
    ]
  ])
}

resource "google_project_iam_member" "sn_access" {
  count      = length(local.iam_bindings)
  project    = var.project
  role       = local.iam_bindings[count.index].role
  member     = local.iam_bindings[count.index].member
  depends_on = [google_project_service.gcp_apis]
}

# Grant permissions to the project service account that will be impersonated by StreamNative Cloud service account
locals {
  streamnative_bootstrap_gsa_name = format("snbootstrap-%s", var.streamnative_org_id)
  streamnative_bootstrap_roles    = local.is_impersonation_enabled ? local.roles : []
  impersonation_roles = [
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountTokenCreator",
  ]
  impersonation_iam_bindings = local.is_impersonation_enabled ? flatten([
    for role in local.impersonation_roles : [
      for gsa in local.streamnative_gsa : {
        role : role,
        member : format("serviceAccount:%s", gsa),
      }
    ]
  ]) : []

}
resource "google_service_account" "sn_bootstrap" {
  count        = local.is_impersonation_enabled ? 1 : 0
  account_id   = local.streamnative_bootstrap_gsa_name
  project      = var.project
  display_name = "StreamNative Bootstrap GSA that will be impersonated by StreamNative Cloud Control Plane."
  depends_on   = [google_project_service.gcp_apis]
}

resource "google_project_iam_member" "sn_bootstrap" {
  count      = length(local.streamnative_bootstrap_roles)
  project    = var.project
  role       = local.streamnative_bootstrap_roles[count.index]
  member     = format("serviceAccount:%s", google_service_account.sn_bootstrap[0].email)
  depends_on = [google_service_account.sn_bootstrap]

  lifecycle {
    precondition {
      condition     = !local.tag_mode || length(local.tag_mode_forbidden_roles) == 0
      error_message = "In tag mode, roles must not contain basic roles (they do not accept conditions), iam.* roles (they can grant impersonation), tag roles (the GSA could tag control plane resources) or custom roles (the module cannot check them). Remove: ${join(", ", local.tag_mode_forbidden_roles)}."
    }
  }

  dynamic "condition" {
    for_each = local.tag_mode && (contains(local.tag_conditioned_roles, local.streamnative_bootstrap_roles[count.index]) || (local.streamnative_bootstrap_roles[count.index] == local.project_iam_admin_role && local.grant_limit_project_iam_admin)) ? [local.streamnative_bootstrap_roles[count.index]] : []
    content {
      title       = condition.value == local.project_iam_admin_role ? "sn-grantable-roles-only" : "sn-resource-tag-${var.resource_tag_value}"
      description = condition.value == local.project_iam_admin_role ? "Allow grants of the data plane roles only" : "Allow resources tagged ${var.resource_tag_key}=${var.resource_tag_value} only"
      expression  = condition.value == local.project_iam_admin_role ? local.grantable_roles_condition : local.resource_tag_condition
    }
  }
}

resource "google_service_account_iam_member" "sn_bootstrap_impersonation" {
  count              = length(local.impersonation_iam_bindings)
  service_account_id = google_service_account.sn_bootstrap[0].id
  role               = local.impersonation_iam_bindings[count.index].role
  member             = local.impersonation_iam_bindings[count.index].member
  depends_on         = [google_service_account.sn_bootstrap]
}


output "google_services" {
  value       = local.google_services
  description = "Enabled google services."
}

output "iam_bindings" {
  value       = local.iam_bindings
  description = "Configured iam policies."
}

output "impersonation_iam_bindings" {
  value       = local.impersonation_iam_bindings
  description = "Configured iam policies for impersonation."
}
