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
  description = "The name of the resource group where the AKS cluster will be created"
}

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group where the AKS cluster will be created"
}

variable "streamnative_org_id" {
  description = "Your Organization ID within StreamNative Cloud, used for all resources created by the module. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
  type        = string
}

variable "dns_zone_ids" {
  type        = list(string)
  description = "The DNS zone IDs for the DNS zones that will be used for the AKS cluster"
  default     = []
}
