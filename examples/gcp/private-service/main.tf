locals {
  region     = "us-east1"
  project_id = "<your-project-name>"
}

provider "google" {
  region  = local.region
  project = local.project_id
}


# Expose Private Pulsar Service to all regions in network default
module "gcp-private-service-core" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/private-service?ref=v3.3.1"

  region              = local.region
  network_name        = "default"
  subnet_name         = "default"
  domain_name         = "gcp-use1-prod-snc.o-xxxx.g.snio.cloud"
  service_attachment  = "projects/<pulsar-project-name>/regions/us-east1/serviceAttachments/pulsar-private-service"
  cross_region_access = true
  suffix              = "core"
}


# Expose Private Pulsar Service to region us-east1 in network svc2
module "gcp-private-service-svc2" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/private-service?ref=v3.3.1"

  region             = local.region
  network_name       = "svc2"
  subnet_name        = "svc2"
  domain_name         = "gcp-use1-prod-snc.o-xxxx.g.snio.cloud"
  service_attachment = "projects/<pulsar-project-name>/regions/us-east1/serviceAttachments/pulsar-private-service"
  cross_region_access = false
  suffix             = "svc2"
}

