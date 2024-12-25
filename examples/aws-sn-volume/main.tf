provider "aws" {
  region = "us-west-2"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws/sn-volume-access"

  external_id = "max"
  bucket      = "test-ursa-storage"
  path        = "ursa"

  oidc_providers = []

  streamnative_vendor_access_role_arns = []
}