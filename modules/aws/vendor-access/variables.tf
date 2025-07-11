## Copyright 2023 StreamNative, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

variable "sn_policy_version" {
  description = "The value of SNVersion tag"
  default     = "3.22.1"  # {{ x-release-please-version }}
  type        = string
}

variable "s3_kms_key_arns" {
  default     = []
  description = "List of KMS key ARNs to use for S3 buckets"
  type        = list(string)
}

variable "additional_iam_policy_arns" {
  default     = []
  description = "Provide a list of additional IAM policy arns allowed for use with iam:AttachRolePolicy, defined in the StreamNativePermissionBoundary."
  type        = list(string)
}

variable "create_bootstrap_role" {
  default     = true
  description = "Whether or not to create the bootstrap role, which is used by StreamNative for the initial deployment of the StreamNative Cloud"
  type        = string

}

variable "ebs_kms_key_arns" {
  default     = []
  description = "Sets the list of allowed kms key arns, if not set, uses the default ebs kms key"
  type        = list(any)
}

variable "eks_cluster_pattern" {
  default     = "*snc*"
  description = "Defines the eks clsuter prefix for streamnative clusters. This should normally remain the default value."
  type        = string
}

variable "external_id" {
  default     = ""
  description = "A external ID that correspond to your Organization within StreamNative Cloud, used for all STS assume role calls to the IAM roles created by the module. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
  type        = string
}

variable "external_ids" {
  default     = []
  description = "A list of external IDs that correspond to your Organization within StreamNative Cloud, used for all STS assume role calls to the IAM roles created by the module. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
  type        = list(string)
}

variable "hosted_zone_allowed_ids" {
  default     = ["*"]
  description = "Allows for further scoping down policy for allowed hosted zones. The IDs provided are constructed into ARNs"
  type        = list(any)
}

variable "region" {
  default     = "*"
  description = "The AWS region where your instance of StreamNative Cloud is deployed. Defaults to all regions \"*\""
  type        = string
}

variable "s3_bucket_pattern" {
  default     = "*snc*"
  description = "Defines the bucket prefix for streamnative managed buckets (backup and offload). Typically defaults to \"snc-*\", but should match the bucket created using the tiered-storage-resources module"
  type        = string
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

variable "streamnative_google_account_id" {
  default     = "108050666045451143798"
  description = "(Deprecated, use streamnative_google_account_ids instead) The Google Cloud service account ID used by StreamNative for Control Plane operations"
  type        = string
}

variable "streamnative_google_account_ids" {
  default     = ["108050666045451143798"]
  description = "The Google Cloud service account IDs used by StreamNative for Control Plane operations"
  type        = list(string)
}

variable "streamnative_vendor_access_role_arns" {
  default     = ["arn:aws:iam::311022431024:role/cloud-manager"]
  description = "A list ARNs provided by StreamNative that enable us to work with the Vendor Access Roles created by this module (StreamNativeCloudBootstrapRole, StreamNativeCloudManagementRole). This is how StreamNative is granted access into your AWS account, and should typically be the default value unless directed otherwise. This arns are used *only* for automations."
  type        = list(string)
}

variable "streamnative_support_access_role_arns" {
  default     = ["arn:aws:iam::311022431024:role/cloud-support-general"]
  description = "A list ARNs provided by StreamNative that enable streamnative support engineers access the StreamNativeCloudBootstrapRole. This is used only in some initial provisioning and in case of on-call support."
  type        = list(string)
}

variable "streamnative_principal_ids" {
  default     = []
  description = "When set, this applies an additional check for certain StreamNative principals to futher restrict access to which services / users can access an account."
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = "Extra tags to apply to the resources created by this module."
  type        = map(string)
}

variable "test_suffix" {
  default     = ""
  description = "Used in testing to apply us to apply multiple versions of the role"
  type        = string
}

variable "vpc_allowed_ids" {
  default     = ["*"]
  description = "Allows for further scoping down policy for allowed VPC"
  type        = list(any)
}

variable "write_policy_files" {
  default     = false
  description = "Write the policy files locally to disk for debugging and validation"
  type        = bool
}

variable "enforce_vendor_federation" {
  default     = false
  description = "Do not enable this unless explicitly told to do so by StreamNative. Restrict access for the streamnative_vendor_access_role_arns to only federated Google accounts. Intended to be true by default in the future."
  type        = bool
}
