locals {
  dns_name                      = "${var.domain_name}."
  network_project               = var.network_project != "" ? var.network_project : var.project
  enable_topology_aware_gateway = length(var.service_attachments) > 0
  service_attachments = {
    for idx, sa in var.service_attachments : sa.zone => sa.id
  }
}


data "google_compute_network" "network" {
  name    = var.network_name
  project = local.network_project
}

data "google_compute_subnetwork" "subnet" {
  name    = var.subnet_name
  region  = var.region
  project = local.network_project
}

resource "google_compute_address" "psc_endpoint_address" {
  count        = local.enable_topology_aware_gateway ? 0 : 1
  name         = "pulsar-psc-${var.suffix}"
  region       = var.region
  subnetwork   = data.google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
  project      = local.network_project
}

resource "google_compute_address" "psc_endpoint_addresses" {
  for_each     = local.service_attachments
  name         = "pulsar-psc-${var.suffix}-${each.key}"
  region       = var.region
  subnetwork   = data.google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
  project      = local.network_project
}


resource "google_dns_managed_zone" "psc_endpoint_zone" {
  name       = "pulsar-psc-${var.suffix}"
  dns_name   = local.dns_name
  project    = var.project
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = data.google_compute_network.network.id
    }
  }
}

resource "google_dns_record_set" "wildcard_endpoint" {
  count        = local.enable_topology_aware_gateway ? 0 : 1
  managed_zone = google_dns_managed_zone.psc_endpoint_zone.name
  name         = "*.${local.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.psc_endpoint_address[0].address]
  project      = var.project
}


resource "google_dns_record_set" "zonal_wildcard_endpoint" {
  count        = local.enable_topology_aware_gateway ? 1 : 0
  managed_zone = google_dns_managed_zone.psc_endpoint_zone.name
  name         = "*.${local.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas = [
    for zone, id in local.service_attachments : google_compute_address.psc_endpoint_addresses[zone].address
  ]
  project = var.project
}

resource "google_dns_record_set" "zonal_endpoint" {
  for_each     = local.service_attachments
  managed_zone = google_dns_managed_zone.psc_endpoint_zone.name
  name         = "*.${each.key}.${local.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.psc_endpoint_addresses[each.key].address]
  project      = var.project
}

resource "google_compute_forwarding_rule" "psc_endpoint" {
  count                   = local.enable_topology_aware_gateway ? 0 : 1
  name                    = "pulsar-psc-${var.suffix}"
  region                  = var.region
  load_balancing_scheme   = ""
  allow_psc_global_access = var.cross_region_access
  target                  = var.service_attachment
  network                 = data.google_compute_network.network.id
  ip_address              = google_compute_address.psc_endpoint_address[0].id
  project                 = var.project
}

resource "google_compute_forwarding_rule" "zonal_psc_endpoint" {
  for_each                = local.service_attachments
  name                    = "pulsar-psc-${var.suffix}-${each.key}"
  region                  = var.region
  load_balancing_scheme   = ""
  allow_psc_global_access = var.cross_region_access
  target                  = each.value
  network                 = data.google_compute_network.network.id
  ip_address              = google_compute_address.psc_endpoint_addresses[each.key].id
  project                 = var.project
}

output "network_id" {
  value = data.google_compute_network.network.id
}

output "endpoint_addresses" {
  value = local.enable_topology_aware_gateway ? [
    for zone, id in local.service_attachments : google_compute_address.psc_endpoint_addresses[zone].address
  ] : [google_compute_address.psc_endpoint_address[0].address]
}
