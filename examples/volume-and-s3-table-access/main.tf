module "sn_managed_cloud_access_bucket" {
  source = "../../modules/aws/volume-access"

  external_id = "<your-organization>"
  role        = "<your-role-name>"
  buckets = [
  ]

  account_ids = [
  ]
}

module "sn_managed_cloud_access_s3_table" {
  source     = "../../modules/aws/s3-table-access"
  role       = module.sn_managed_cloud_access_bucket.role
  s3_tables  = []
  depends_on = [module.sn_managed_cloud_access_bucket]
}