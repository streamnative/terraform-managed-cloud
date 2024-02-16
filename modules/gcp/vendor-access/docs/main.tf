provider "google" {
  project = "<YOUR_PROJECT>"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/vendor-access?ref=v3.7.0"
  project = "<YOUR_PROJECT>"
}