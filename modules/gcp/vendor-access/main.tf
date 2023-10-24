locals {
  streamnative_gsa = concat(var.streamnative_vendor_access_gsa, var.streamnative_support_access_gsa)
  iam_bindings = flatten([
    for role in var.roles : [
      for gsa in local.streamnative_gsa : {
        role : role,
        member : format("serviceAccount:%s", gsa),
      }
    ]
  ])
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

resource "google_project_iam_member" "sn_access" {
  for_each = {
    for index, binding in local.iam_bindings :
    index => binding
  }
  project    = var.project
  role       = each.value.role
  member     = each.value.member
  depends_on = [google_project_service.gcp_apis]
}

output "google_services" {
  value = local.google_services
  description = "Enabled google services."
}

output "iam_bindings" {
  value = local.iam_bindings
  description = "Configured iam policies."
}
