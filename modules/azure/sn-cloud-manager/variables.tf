# Copyright 2023 StreamNative, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "additional_tags" {
  default     = {}
  description = "Additional tags to be added to the resources created by this module."
  type        = map(any)
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the cloud manager IAMs will be created"
  default     = ""
}

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group where the cloud manager IAMs will be created"
}

variable "streamnative_automation_gsa_ids" {
  default = {
    cloud_manager_sncloud_test_iam_gserviceaccount_com         = "103687585001802233900",
    pool_automation_sncloud_test_iam_gserviceaccount_com       = "101134291802756860252",
    cloud_support_general_sncloud_test_iam_gserviceaccount_com = "103182365501883681520",
  }
  type        = map(string)
  description = "The GSAs will be used to provisioning StreamnNative cloud."
}

variable "streamnative_support_access_gsa_ids" {
  default = {
    cloud_support_general_sncloud_test_iam_gserviceaccount_com = "103182365501883681520",
  }
  type        = map(string)
  description = "The GSA will be used by StreamnNative support team."
}

variable "streamnative_org_id" {
  description = "Your Organization ID within StreamNative Cloud, used for all resources created by the module. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
  type        = string
}
