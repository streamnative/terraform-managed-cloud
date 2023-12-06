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

output "sn_automation_client_id" {
  value       = data.azuread_application.sn_automation.client_id
  description = "The client ID of the sn automation service principal for StreamNative Cloud automation"
}

output "sn_automation_principal_id" {
  value       = data.azuread_service_principal.sn_automation.id
  description = "The principal ID of the sn automation service principal for StreamNative Cloud automation"
}

output "sn_support_client_id" {
  value       = data.azuread_application.sn_support.client_id
  description = "The client ID of the sn support service principal for StreamNative Cloud support access"
}

output "sn_support_principal_id" {
  value       = data.azuread_service_principal.sn_support.id
  description = "The principal ID of the sn support service principal for StreamNative Cloud support access"
}

output "streamnative_org_id" {
  value       = var.streamnative_org_id
  description = "An external ID that correspond to your Organization within StreamNative Cloud, used for all managed identities created by the module. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
}

output "resource_group_name" {
  value       = azurerm_resource_group.aks.name
  description = "The name of the resource group where the AKS cluster will be created"
}

output "additional_roles" {
  value = [
    {
      name = azurerm_role_definition.velero_backup_role.name
      id   = azurerm_role_definition.velero_backup_role.id
    }
  ]
  description = "The additional roles created by this module"
}

output "subscription_id" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "The subscription ID of the AKS cluster"
}

output "tenant_id" {
  value       = data.azurerm_subscription.current.tenant_id
  description = "The tenant ID of the AKS cluster"
}
