provider "aws" {
  region = "us-west-2"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws/sn-volume-access"

  external_id = "o-rlgba"
  bucket = "test-bucket-storage"
  path = "bucket-storage"
}