variable "management_resource_group_name" {
  type        = string
  default     = "rg-streamnative-cloud-manager"
  description = "The name of the resource group where the management resources will be created"
}

variable "management_resource_group_location" {
  type        = string
  default     = "eastus"
  description = "The location of the resource group where the management resources will be created"
}

variable "additional_tags" {
  default     = {}
  description = "Additional tags to be added to the resources created by this module."
  type        = map(any)
}

variable "management_managed_identity_name" {
  type        = string
  default     = "streamnative-cloud-manager"
  description = "The name of the managed identity to create for the management resources"
}

variable "aks_resource_group_name" {
  type        = string
  description = "The name of the resource group where the AKS cluster will be created"
}

variable "aks_resource_group_location" {
  type        = string
  description = "The location of the resource group where the AKS cluster will be created"
}

variable "streamnative_vendor_access_gsa_ids" {
  default = {
    cloud_manager   = "103687585001802233900", #"cloud-manager@sncloud-test.iam.gserviceaccount.com"
    pool_automation = "101134291802756860252", #"pool-automation@sncloud-test.iam.gserviceaccount.com",
  }
  type        = map(string)
  description = "The GSA will be used by StreamnNative cloud."
}

variable "streamnative_support_access_gsa_ids" {
  default = {
    cloud_support_general = "103182365501883681520", #cloud-support-general@sncloud-test.iam.gserviceaccount.com
  }
  type        = map(string)
  description = "The GSA will be used by StreamnNative support team."
}

variable "streamnative_external_id" {
  description = "An external ID that correspond to your Organization within StreamNative Cloud, used for all managed identities created by the module. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the DNS zone to create for the management resources, if provided"
  type        = string
  default     = null
}
