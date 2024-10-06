locals {
  streamnative_gsa = formatlist("serviceAccount:%s", concat(var.streamnative_vendor_access_gsa, var.streamnative_support_access_gsa))
  iam_bindings = flatten([
    for role in var.roles : [
      for gsa in local.streamnative_gsa : {
        role : role,
        member : gsa,
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

# resource "google_project_iam_member" "sn_access" {
#   for_each = {
#     for index, binding in local.iam_bindings :
#     index => binding
#   }
#   project    = var.project
#   role       = each.value.role
#   member     = each.value.member
#   depends_on = [google_project_service.gcp_apis]
# }

locals {
  comput_network_user_gsa = var.network_project != "" ? concat(local.streamnative_gsa, [format("serviceAccount:%s@cloudservices.gserviceaccount.com", var.project_num)]) : []
  comput_network_user_iam_binding = flatten([
    for subnet in var.shared_vpc_subnets : [
      for gsa in local.comput_network_user_gsa : {
        region : subnet.region,
        subnet : subnet.name,
        member : gsa,
      }
    ]
  ])
  container_host_service_agent_user = var.network_project != "" ? [format("serviceAccount:service-%s@container-engine-robot.iam.gserviceaccount.com", var.project_num)] : []
}

resource "google_compute_subnetwork_iam_member" "network_user" {
  for_each = {
    for index, binding in local.comput_network_user_iam_binding :
    index => binding
  }
  project    = var.network_project
  region     = each.value.region
  subnetwork = each.value.subnet
  role       = "roles/compute.networkUser"
  member     = each.value.member
  depends_on = [google_project_service.gcp_apis]
}

resource "google_project_iam_member" "service_agent_user" {
  count      = length(local.container_host_service_agent_user)
  project    = var.network_project
  role       = "roles/container.hostServiceAgentUser"
  member     = local.container_host_service_agent_user[count.index]
  depends_on = [google_project_service.gcp_apis]
}

output "google_services" {
  value       = local.google_services
  description = "Enabled google services."
}

output "iam_bindings" {
  value       = local.iam_bindings
  description = "Configured iam policies."
}
