provider "google" {
  project = "<YOUR_PROJECT>"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/vendor-access?ref=v3.15.0"
  project = "<YOUR_PROJECT>"
  streamnative_org_id = "<YOUR_ORG_ID>"
}