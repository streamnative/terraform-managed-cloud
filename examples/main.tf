module "aws-managed-cloud" {
  source = "../aws"

  external_ids = ["*"]

}

provider "aws" {
  region = "us-west-2"
}