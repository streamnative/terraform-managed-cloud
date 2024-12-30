variable "sn_policy_version" {
  description = "The value of SNVersion tag"
  default     = "3.16.1" # {{ x-release-please-version }}
  type        = string
}

variable "region" {
  default     = "*"
  description = "The AWS region where your instance of StreamNative Cloud is deployed. Defaults to all regions \"*\""
  type        = string
}

variable "streamnative_vendor_access_role_arns" {
  default     = ["arn:aws:iam::311022431024:role/cloud-manager"]
  description = "This role for access customer s3 bucket on control plane."
  type        = list(string)
}

variable "additional_federated_identifiers" {
  default     = []
  description = "This federated identified list for access customer s3 bucket on data plane."
  type        = list(string)
}

variable "streamnative_principal_ids" {
  default     = []
  description = "When set, this applies an additional check for certain StreamNative principals to futher restrict access to which services / users can access an account."
  type        = list(string)
}

variable "source_identities" {
  default     = []
  description = "Place an additional constraint on source identity, disabled by default and only to be used if specified by StreamNative"
  type        = list(any)
}

variable "source_identity_test" {
  default     = "ForAnyValue:StringLike"
  description = "The test to use for source identity"
  type        = string
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

variable "enforce_vendor_federation" {
  default     = false
  description = "Do not enable this unless explicitly told to do so by StreamNative. Restrict access for the streamnative_vendor_access_role_arns to only federated Google accounts. Intended to be true by default in the future."
  type        = bool
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