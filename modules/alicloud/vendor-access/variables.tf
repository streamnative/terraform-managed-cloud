terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "1.248.0"
    }
  }
}

variable "organization_ids" {
  description = "The ID of your organization on StreamNative Cloud."
  type        = list(string)
}

variable "region" {
  default     = "*"
  description = "The aliyun region where your StreamNative Cloud Environment can be deployed. Defaults to all regions."
}

variable "streamnative_cloud_manager_role_arns" {
  default     = ["acs:ram::5855446584058772:role/cloud-manager"]
  description = "The list of StreamNative cloud manager role ARNs. This is used to grant StreamNative cloud manager to your environment."
  type        = list(string)
}

variable "streamnative_support_role_arns" {
  default     = ["acs:ram::5855446584058772:role/support-general"]
  description = "The list of StreamNative support role ARNs. This is used to grant StreamNative support to your environment."
  type        = list(string)
}