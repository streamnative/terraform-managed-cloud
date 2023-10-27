provider "google" {
  alias = "source"

  project = var.source_project
}

provider "google" {
  alias = "target"

  project = var.target_project
}

resource "google_dns_managed_zone" "target" {
  provider = google.target

  name     = var.target_zone_name
  dns_name = var.target_zone_dns_name
}

data "google_dns_managed_zone" "source" {
  provider = google.source

  name = var.source_zone_name
}

resource "google_dns_record_set" "delegate" {
  provider = google.source

  managed_zone = data.google_dns_managed_zone.source.name
  name         = google_dns_managed_zone.target.dns_name
  type         = "NS"
  ttl          = "300"
  rrdatas      = google_dns_managed_zone.target.name_servers
}
