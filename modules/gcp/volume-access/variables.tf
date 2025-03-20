variable "streamnative_vendor_access_gsa" {
  default = [
    "cloud-manager@sncloud-production.iam.gserviceaccount.com"
  ]
  type        = list(string)
  description = "The GSA will be used by StreamnNative cloud."
}

variable "account_id" {
  type        = string
  description = "Google Service Account ID, <id>@<your-project>.iam.gserviceaccount.com"
}

variable "project" {
  type        = string
  description = "Name of the project that your gcs bucket is located in"
}

variable "cluster_projects" {
  type        = list(string)
  description = "The name of the project your ursa cluster belongs to."
}

variable "buckets" {
  description = "User bucket and path name"
  type        = list(string)
}