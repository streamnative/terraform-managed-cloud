module "aws-managed-cloud" {
  source = "../modules/aws"

  external_ids = ["*"]

  write_policy_files = true
}

provider "aws" {
  region = "us-west-2"
}