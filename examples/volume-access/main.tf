module "sn_managed_cloud" {
  source = "../../modules/aws/volume-access"

  external_id = "max"
  role = "sn-test-ursa-accoss-account"
  buckets      = []

  account_ids = []

  streamnative_vendor_access_role_arns = []
}