provider "aws" {
  region = "us-west-2"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws/aws-sn-volume"

  external_id = "o-rlgba"
}