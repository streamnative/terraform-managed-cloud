module "sn_managed_cloud_access_bucket" {
  source = "../../../modules/gcp/volume-access"

  streamnative_org_id = "<your-org-id>"
  project             = "<your-gcs-bucket-project-name>"

  cluster_projects = [
    "<your-ursa-cluster-project-name>"
  ]

  account_id = "<your-google-service-account-id>"

  buckets = [
    "<your-gcs-bucket-path>"
  ]
}