variable "sn_policy_version" {
  description = "The value of SNVersion tag"
  default     = "3.16.1" # {{ x-release-please-version }}
  type        = string
}

variable "streamnative_vendor_access_role_arns" {
  default     = ["arn:aws:iam::311022431024:role/cloud-manager"]
  description = "This role for access customer s3 bucket on control plane."
  type        = list(string)
}

variable "external_id" {
  default     = ""
  description = "A external ID that correspond to your Organization within StreamNative Cloud, used for all STS assume role calls to the IAM roles created by the module. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
  type        = string
}

variable "tags" {
  default     = {}
  description = "Extra tags to apply to the resources created by this module."
  type        = map(string)
}

variable "bucket" {
  description = "User bucket name"
  type        = string
}

variable "path" {
  description = "S3 bucket path"
  type        = string
}

variable "oidc_providers" {
  default     = []
  description = "Your aws eks cluster OIDC Providers"
  type        = list(string)
}

variable "init_oidc_providers" {
  default     = true
  description = ""
  type        = bool
}