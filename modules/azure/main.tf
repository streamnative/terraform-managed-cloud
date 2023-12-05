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

data "azurerm_subscription" "current" {
}

locals {
  tags = merge({
    "Vendor"  = "StreamNative"
    "Service" = "StreamNative Cloud"
  }, var.additional_tags)
}

# Create a resource group for the AKS cluster
resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = local.tags
}

# Create the Velero `VeleroBackupRole` for at the resource group level
resource "azurerm_role_definition" "velero_backup_role" {
  name        = "VeleroBackupRole"
  description = "The role grants the minimum required permissions needed by Velero to perform backups, restores, and deletions. Reference: https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure?tab=readme-ov-file#specify-role"
  scope       = azurerm_resource_group.aks.id
  permissions {
    actions = [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/snapshots/read",
      "Microsoft.Compute/snapshots/write",
      "Microsoft.Compute/snapshots/delete",
      "Microsoft.Storage/storageAccounts/listkeys/action",
      "Microsoft.Storage/storageAccounts/regeneratekey/action",
      "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action",
      "Microsoft.Storage/storageAccounts/read"
    ]
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action"
    ]
    not_data_actions = []
    not_actions      = []
  }
}

# Grand the sn automation service principal as the Contributor to the AKS resource group
resource "azurerm_role_assignment" "sn_automation" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.sn_automation.id
}

# Grand the sn automation service principal as the Azure Kubernetes Service Cluster Admin Role to the AKS resource group
resource "azurerm_role_assignment" "sn_automation_cluster_admin" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_service_principal.sn_automation.id
}

# Grand the sn support service principal as the Azure Kubernetes Service Cluster User Role to the AKS resource group
resource "azurerm_role_assignment" "sn_support" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_service_principal.sn_support.id
}

# Grand the sn automation service principal as the Constrain roles by User Access Administrator to the AKS resource group
resource "azurerm_role_assignment" "user_access_administrator" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.sn_automation.id
  condition_version    = "2.0"
  condition            = <<-EOT
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
 )
 OR 
 (
  @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1, 4d97b98b-1d4f-4787-a291-c67834d212e7, befefa01-2a29-4197-83a8-272ff33ce314, acdd72a7-3385-48ef-bd42-f606fba81ae7, ba92f5b4-2d11-453d-a403-e96b0029c9fe, $(resource.azurerm_role_definition.velero_backup_role.role_definition_id)}
  AND
  @Request[Microsoft.Authorization/roleAssignments:PrincipalType] ForAnyOfAnyValues:StringEqualsIgnoreCase {'ServicePrincipal'}
 )
)
AND
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
 )
 OR 
 (
  @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1, 4d97b98b-1d4f-4787-a291-c67834d212e7, befefa01-2a29-4197-83a8-272ff33ce314, acdd72a7-3385-48ef-bd42-f606fba81ae7, ba92f5b4-2d11-453d-a403-e96b0029c9fe, $(resource.azurerm_role_definition.velero_backup_role.role_definition_id)}
  AND
  @Resource[Microsoft.Authorization/roleAssignments:PrincipalType] ForAnyOfAnyValues:StringEqualsIgnoreCase {'ServicePrincipal'}
 )
)
EOT
}

