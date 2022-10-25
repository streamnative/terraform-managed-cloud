provider "aws" {
  region = "us-west-2"
}

module "aws-managed-cloud" {
  source  = "github.com/streamnative/terraform-managed-cloud//modules/aws?ref=v3.0.0"

  external_id             = "o-kxb4r"
  hosted_zone_allowed_ids = ["Z00048871IAX8IX9HGD0"]
  region                  = "us-west-2"
  write_policy_files      = true # Writes the rendered policy files to the `policy_files` directory, found in this example

}
