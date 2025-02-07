variable "sn_policy_version" {
  description = "The value of SNVersion tag"
  default     = "3.16.1" # {{ x-release-please-version }}
  type        = string
}

variable "tags" {
  default     = {}
  description = "Extra tags to apply to the resources created by this module."
  type        = map(string)
}

variable "s3_tables" {
  default     = []
  description = "User s3 tables and path name"
  type        = list(string)
}

variable "role" {
  description = "Your aws iam role for access s3 bucket"
  type        = string
}
