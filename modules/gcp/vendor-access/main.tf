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
    for role in var.roles : [
      for gsa in local.streamnative_gsa : {
        role : role,
        member : format("serviceAccount:%s", gsa),
      }
    ]
  ])
}

resource "google_project_iam_member" "sn_access" {
  count = length(local.iam_bindings)
  project    = var.project
  role       = local.iam_bindings[count.index].role
  member     = local.iam_bindings[count.index].member
  depends_on = [google_project_service.gcp_apis]
}

# Grant permissions to the project service account that will be impersonated by StreamNative Cloud service account
locals {
  streamnative_bootstrap_gsa_name = format("snbootstrap-%s", var.streamnative_org_id)
  streamnative_bootstrap_roles    = local.is_impersonation_enabled ? var.roles : []
  impersonation_roles = [
    # "roles/iam.serviceAccountUser",
    # "roles/iam.serviceAccountAdmin",
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
  count        = local.is_impersonation_enabled && var.existing_service_account_id == "" ? 1 : 0
  account_id   = local.streamnative_bootstrap_gsa_name
  project      = var.project
  display_name = "StreamNative Bootstrap GSA that will be impersonated by StreamNative Cloud Control Plane."
  depends_on   = [google_project_service.gcp_apis]
}

data "google_service_account" "sn_bootstrap" {
  count        = local.is_impersonation_enabled && var.existing_service_account_id != "" ? 1 : 0
  account_id   = var.existing_service_account_id
  project      = var.project
  depends_on   = [google_project_service.gcp_apis]
}

locals {
  sn_bootstrap_email = var.existing_service_account_id == "" ? google_service_account.sn_bootstrap[0].email : data.google_service_account.sn_bootstrap[0].email
  sn_bootstrap_id = var.existing_service_account_id == "" ? google_service_account.sn_bootstrap[0].id : data.google_service_account.sn_bootstrap[0].id
}

resource "google_project_iam_member" "sn_bootstrap" {
  count      = length(local.streamnative_bootstrap_roles)
  project    = var.project
  role       = local.streamnative_bootstrap_roles[count.index]
  member     = format("serviceAccount:%s", local.sn_bootstrap_email)
}

resource "google_service_account_iam_member" "sn_bootstrap_impersonation" {
  count              = length(local.impersonation_iam_bindings)
  service_account_id = local.sn_bootstrap_id
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
