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

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group where the AKS cluster will be created"
}

variable "streamnative_automation_gsa_ids" {
  default = {
    cloud_manager_sncloud_test_iam_gserviceaccount_com   = "103687585001802233900",
    pool_automation_sncloud_test_iam_gserviceaccount_com = "101134291802756860252",
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

variable "external_id" {
  description = "An external ID that correspond to your Organization within StreamNative Cloud, used for all managed identities created by the module. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
  type        = string
}
