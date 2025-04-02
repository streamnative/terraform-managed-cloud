variable "streamnative_org_id" {
  type        = string
  description = "Your Organization ID within StreamNative Cloud. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
  validation {
    condition     = length(var.streamnative_org_id) <= 18
    error_message = "The organization ID must not exceed 18 characters. If you reach this limit, please contact StreamNative support."
  }
}

variable "streamnative_vendor_access_gsa" {
  default = [
    "cloud-manager@sncloud-production.iam.gserviceaccount.com"
  ]
  type        = list(string)
  description = "The GSA will be used by StreamnNative cloud."
}

variable "google_service_account_id" {
  type        = string
  description = "Google Service Account ID, <id>@<your-project>.iam.gserviceaccount.com, ref https://cloud.google.com/iam/docs/service-accounts-create#creating"
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

  validation {
    condition = alltrue([
      for s in var.buckets : length(split("/", s)) >= 2
    ])
    error_message = "Invalid bucket path found, please make sure the bucket contains at least one path <bucket-name>/<bucket-path>"
  }
}