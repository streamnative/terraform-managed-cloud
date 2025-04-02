module "sn_managed_cloud_access_bucket" {
  source = "../../../modules/gcp/volume-access"

  streamnative_org_id = "<your-org-id>"
  project             = "<your-gcs-bucket-project-name>"

  cluster_projects = [
    "<your-ursa-cluster-project-name>"
  ]

  # https://cloud.google.com/iam/docs/service-accounts-create#creating
  google_service_account_id = "<your-google-service-account-id>"

  buckets = [
    "<your-gcs-bucket-path>"
  ]
}