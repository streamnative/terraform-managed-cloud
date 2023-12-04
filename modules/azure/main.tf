data "azurerm_subscription" "current" {
}

locals {
  streamnative_gsa = merge(var.streamnative_vendor_access_gsa_ids, var.streamnative_support_access_gsa_ids)
  tags = merge({
    "Vendor"  = "StreamNative"
    "Service" = "StreamNative Cloud"
  }, var.additional_tags)
}

# Create a resource group for the management resources
resource "azurerm_resource_group" "sn_access" {
  name     = var.management_resource_group_name
  location = var.management_resource_group_location
  tags     = local.tags
}

# Create a managed identity for the management resources
resource "azurerm_user_assigned_identity" "sn_access" {
  name                = var.management_managed_identity_name
  resource_group_name = azurerm_resource_group.sn_access.name
  location            = azurerm_resource_group.sn_access.location
}

# Create federated identity credentials for the user assigned identity with the list of streamnative GSAs
# external ID is used to scope down the access to the specific organization
resource "azurerm_federated_identity_credential" "sn_access" {
  for_each            = local.streamnative_gsa
  name                = each.key
  resource_group_name = azurerm_resource_group.sn_access.name
  audience            = [format("api://AzureADTokenExchange/%s", var.streamnative_external_id)]
  issuer              = "https://accounts.google.com"
  parent_id           = azurerm_user_assigned_identity.sn_access.id
  subject             = each.value
}

# Grand the user assigned identity as Conrtibutor role to the management resource group
resource "azurerm_role_assignment" "sn_access" {
  scope                = azurerm_resource_group.sn_access.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.sn_access.principal_id
}

# Create the DNS zone for the management resources if provided
resource "azurerm_dns_zone" "sn_access" {
  count               = var.dns_zone_name != null ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.sn_access.name
}

# Create the Velero `VeleroBackupRole` for at the subscription level
resource "azurerm_role_definition" "velero_backup_role" {
  name        = "VeleroBackupRole"
  description = "The role grants the minimum required permissions needed by Velero to perform backups, restores, and deletions. Reference: https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure?tab=readme-ov-file#specify-role"
  scope       = data.azurerm_subscription.current.subscription_id
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

####################

# Create a resource group for the AKS cluster
resource "azurerm_resource_group" "aks" {
  name     = var.aks_resource_group_name
  location = var.aks_resource_group_location
  tags     = local.tags
}

# Grand the user assigned identity as Conrtibutor role to the AKS resource group
resource "azurerm_role_assignment" "aks" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.sn_access.principal_id
}

# Grand the user assigned identity as the Constrain roles by User Access Administrator to the AKS resource group
resource "azurerm_role_assignment" "aks_user_access_administrator" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "User Access Administrator"
  principal_id         = azurerm_user_assigned_identity.sn_access.principal_id
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

