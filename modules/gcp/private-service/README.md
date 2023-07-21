# StreamNative Cloud - Managed GCP Private Service

This Terraform modules configures your GCP network to access private StreamNative BYOC pulsar service.

## QuickStart
Run the following terraform file with GCP Configuration:

```hcl
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
```
1. terraform init
1. terraform plan
1. terraform apply



## Examples

More examples of the modules can be found in the `examples/gcp/private-service` directory.
