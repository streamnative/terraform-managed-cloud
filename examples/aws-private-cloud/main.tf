provider "aws" {
  region = "us-west-2"
}

# Private cloud: the customer runs the deployment Terraform, so StreamNative
# gets no role in the account. The module still creates the permission
# boundary, runtime and load balancer controller policies that the cluster
# components use.
module "aws_vendor_access" {
  source = "../../modules/aws/vendor-access"

  external_id                 = "o-kxb4r"
  region                      = "us-west-2"
  create_bootstrap_role       = false
  enable_support_access       = false
  enable_cloud_manager_access = false
}

output "permission_boundary_policy_arn" {
  value = module.aws_vendor_access.permission_boundary_policy_arn
}

output "runtime_policy_arn" {
  value = module.aws_vendor_access.runtime_policy_arn
}

output "aws_lbc_policy_arn" {
  value = module.aws_vendor_access.aws_lbc_policy_arn
}
