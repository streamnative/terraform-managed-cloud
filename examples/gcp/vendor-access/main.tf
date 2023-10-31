# Grant access
module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/vendor-access?ref=v3.8.0"
  project = "<YOUR_PROJECT>"
}

# Grant access when using shared vpc
module "sn_managed_cloud_shared_vpc" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/vendor-access?ref=v3.8.0"
  project = "<YOUR_PROJECT>"
  project_num = "<YOUR_PROJECT_NUM>"
  network_project = "<YOUR_NETWORK_HOST_PROJECT>"
}