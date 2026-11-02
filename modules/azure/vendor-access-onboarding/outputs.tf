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

output "discovery_hint" {
  description = "Untrusted, minimal four-field discovery hint; automatically submitted when callback is enabled."
  value       = local.discovery_hints
}

output "identity_metadata" {
  description = "Installer verification metadata. These extra fields are never sent in the hint POST."
  value = {
    trust_revision        = local.trust_revision
    environment           = var.environment
    bootstrap_resource_id = azurerm_resource_group.bootstrap.id
    operational = { for name, identity in azurerm_user_assigned_identity.operational : name => {
      resource_id  = identity.id
      principal_id = identity.principal_id
      client_id    = identity.client_id
    } }
    policy_principals = { for name, assignment in azurerm_subscription_policy_assignment.grant : name => assignment.identity[0].principal_id }
  }
}

output "workload_contract" {
  description = "Canonical installer-created workload groups and required tags for the verification targets."
  value = {
    prefix             = local.workload_rg_prefix
    tags               = { "sn-organization" = var.organization_name, "sn-managed-by" = "streamnative", "sn-environment" = var.environment }
    ce_key_tag         = "sn-ce"
    workload_group_ids = local.group_ids
  }
}
