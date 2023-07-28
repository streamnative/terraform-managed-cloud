locals {
  region             = "us-east1"
  project_id         = "<your-project-name>"
  network_project_id = "<your-network-project-name>"
}

provider "google" {
  region  = local.region
  project = local.project_id
}


# Expose Private Pulsar Service to all regions in network default
module "gcp-private-service-core" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/private-service?ref=v3.3.1"

  region              = local.region
  project             = local.project_id
  network_name        = "default"
  subnet_name         = "default"
  domain_name         = "gcp-use1-prod-snc.o-xxxx.g.snio.cloud"
  service_attachment  = "projects/<pulsar-project-name>/regions/us-east1/serviceAttachments/pulsar-private-service"
  cross_region_access = true
  suffix              = "core"
}


# Expose Private Pulsar Service to region us-east1 in network svc2
module "gcp-private-service-svc2" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/private-service?ref=v3.4.1"

  region              = local.region
  project             = local.project_id
  network_name        = "svc2"
  subnet_name         = "svc2"
  domain_name         = "gcp-use1-prod-snc.o-xxxx.g.snio.cloud"
  service_attachment  = "projects/<pulsar-project-name>/regions/us-east1/serviceAttachments/pulsar-private-service"
  cross_region_access = false
  suffix              = "svc2"
}


# Expose Private Pulsar Service to shared VPC shared in project <your-network-project-name>
module "gcp-private-service-shared" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/private-service?ref=v3.4.1"

  region              = local.region
  project             = local.project_id
  network_project     = local.network_project_id
  network_name        = "shared"
  subnet_name         = "shared"
  domain_name         = "gcp-use1-prod-snc.o-xxxx.g.snio.cloud"
  service_attachment  = "projects/<pulsar-project-name>/regions/us-east1/serviceAttachments/pulsar-private-service"
  cross_region_access = false
  suffix              = "shared"
}

