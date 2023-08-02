locals {
  dns_name        = "${var.domain_name}."
  network_project = var.network_project != "" ? var.network_project : var.project
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
  name         = "pulsar-psc-${var.suffix}"
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
  managed_zone = google_dns_managed_zone.psc_endpoint_zone.name
  name         = "*.${local.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.psc_endpoint_address.address]
  project      = var.project
}


resource "google_compute_forwarding_rule" "psc_endpoint" {
  name                    = "pulsar-psc-${var.suffix}"
  region                  = var.region
  load_balancing_scheme   = ""
  allow_psc_global_access = var.cross_region_access
  target                  = var.service_attachment
  network                 = data.google_compute_network.network.id
  ip_address              = google_compute_address.psc_endpoint_address.id
  project                 = var.project
}

output "network_id" {
  value = data.google_compute_network.network.id
}

output "endpoint_address" {
  value = google_compute_address.psc_endpoint_address.id
}
