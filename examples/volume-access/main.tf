provider "aws" {
  region = "us-west-2"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws/volume-access"

  external_id = "max"
  bucket      = "test-ursa-storage"
  path        = "ursa"

  oidc_providers = [
    "oidc.eks.us-east-2.amazonaws.com/id/B1C90381FF99EB05EDE1C8E2C2884166",
    "oidc.eks.us-east-2.amazonaws.com/id/9ACC7EF87FC7333990CF6BEFA7CEA816"
  ]

  streamnative_vendor_access_role_arns = [
    "arn:aws:iam::738562057640:role/cloud-manager"
  ]
}