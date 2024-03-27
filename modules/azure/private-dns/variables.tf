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

variable "private_endpoint_name" {
  type        = string
  description = "The name of the Private Endpoint"
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the private endpoint will be created"
  default     = ""
}

variable "vnet_name" {
  type        = string
  description = "The vnet name used for the Private Endpoint"
}

variable "domain" {
  type        = string
  description = "The domain of the Pulsar service endpoint"
}
