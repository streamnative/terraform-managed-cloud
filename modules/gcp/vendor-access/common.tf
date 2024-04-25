variable "project" {
  type        = string
  description = "The project id of the target project"
}

variable "roles" {
  default = [
    "roles/editor",
    "roles/cloudkms.admin",
    "roles/compute.admin",
    "roles/compute.loadBalancerAdmin",
    "roles/compute.networkAdmin",
    "roles/container.admin",
    "roles/dns.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin"
  ]
  type        = list(string)
  description = "The role list will be associated with StreamNative GSA."
}


variable "streamnative_vendor_access_gsa" {
  default = [
    "cloud-manager@sncloud-production.iam.gserviceaccount.com",
    "pool-automation@sncloud-production.iam.gserviceaccount.com"
  ]
  type        = list(string)
  description = "The GSA will be used by StreamnNative cloud."
}

variable "streamnative_support_access_gsa" {
  default     = ["cloud-support-general@sncloud-production.iam.gserviceaccount.com"]
  type        = list(string)
  description = "The GSA will be used by StreamnNative support team."
}

variable "extra_google_services" {
  default     = []
  type        = list(string)
  description = "Extra google API services need to be enabled."
}
