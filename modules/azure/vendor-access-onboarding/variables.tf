# Copyright 2026 StreamNative, Inc.
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

variable "organization_name" {
  description = "Canonical StreamNative organization API namespace, such as o-abc."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?$", var.organization_name))
    error_message = "Use the canonical API namespace: 1-63 lowercase letters, digits or internal hyphens."
  }
}

variable "environment" {
  description = "Selects the fixed StreamNative federation subjects."
  type        = string
  default     = "production"
  validation {
    condition     = contains(["test", "staging", "production"], var.environment)
    error_message = "Environment must match one of the reviewed trust mappings."
  }
}

variable "bootstrap_location" {
  description = "Azure canonical location of the protected onboarding resources."
  type        = string
  default     = "eastus"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.bootstrap_location))
    error_message = "Use the canonical Azure location name, for example eastus."
  }
}

variable "discovery_endpoint" {
  description = "Optional reviewed hint receiver URL. HTTPS or local loopback, with path /v1/azure-discovery/hints."
  type        = string
  default     = null
  validation {
    condition     = var.discovery_endpoint == null ? true : can(regex("^(https://[a-zA-Z0-9.-]+(:[0-9]+)?|http://(127[.]0[.]0[.]1|localhost)(:[0-9]+)?)/v1/azure-discovery/hints$", var.discovery_endpoint))
    error_message = "Use an HTTPS endpoint, or HTTP on localhost/127.0.0.1, without credentials, query or fragment."
  }
}

variable "verification_targets" {
  description = "CE UID keyed verification targets (ce1/ce2 reproduce the historical test); fresh targets in the test federation environment. A nonempty map opts into the subscription policy executors."
  type = map(object({
    location            = string
    aks_name            = string
    node_resource_group = string
  }))
  default  = {}
  nullable = false
  validation {
    condition = length(var.verification_targets) <= 2 && (length(var.verification_targets) == 0 || var.environment == "test") && alltrue([
      for key, target in var.verification_targets :
      (can(regex("^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$", key)) || contains(["ce1", "ce2"], key)) && can(regex("^[a-z0-9]{1,24}$", target.location)) &&
      can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", target.aks_name)) &&
      can(regex("^[a-z0-9][a-z0-9-]{0,79}$", target.node_resource_group)) &&
      !startswith(target.node_resource_group, "snce-") && !startswith(target.node_resource_group, "sncloud-")
    ]) && length(distinct([for t in var.verification_targets : t.node_resource_group])) == length(var.verification_targets)
    error_message = "Use up to two test-only targets with distinct node RGs, lowercase canonical names, and no reserved RG prefixes for node RGs."
  }
}

variable "enable_node_reader_verification" {
  description = "Install two additional paired AKS/node-RG policies to verify caller-dependent Reader propagation."
  type        = bool
  default     = false
  nullable    = false
  validation {
    condition     = !var.enable_node_reader_verification || length(var.verification_targets) > 0
    error_message = "Node Reader verification needs at least one explicitly declared test target."
  }
}
