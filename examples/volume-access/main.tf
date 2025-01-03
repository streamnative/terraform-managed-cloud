module "sn_managed_cloud" {
  source = "../../modules/aws/volume-access"

  external_id = "<your-organization-id>"
  role = "<role-name>"
  buckets      = []

  account_ids = []

  streamnative_vendor_access_role_arns = []
}