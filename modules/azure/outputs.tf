output "management_resource_group_name" {
  value       = azurerm_resource_group.sn_access.name
  description = "The name of the resource group where the management resources will be created"
}

output "management_resource_group_location" {
  value       = azurerm_resource_group.sn_access.location
  description = "The location of the resource group where the management resources will be created"
}

output "management_managed_identity_name" {
  value       = azurerm_user_assigned_identity.sn_access.name
  description = "The name of the managed identity to create for the management resources"
}

output "sn_access_client_id" {
  value       = azurerm_user_assigned_identity.sn_access.client_id
  description = "The client ID of the managed identity to create for the management resources"
}

output "sn_access_principal_id" {
  value       = azurerm_user_assigned_identity.sn_access.principal_id
  description = "The principal ID of the managed identity to create for the management resources"
}

output "sn_access_tenant_id" {
  value       = azurerm_user_assigned_identity.sn_access.tenant_id
  description = "The tenant ID of the managed identity to create for the management resources"
}

output "streamnative_external_id" {
  value       = var.streamnative_external_id
  description = "An external ID that correspond to your Organization within StreamNative Cloud, used for all managed identities created by the module. This will be the organization ID in the StreamNative console, e.g. \"o-xhopj\"."
}

output "aks_resource_group_name" {
  value       = azurerm_resource_group.aks.name
  description = "The name of the resource group where the AKS cluster will be created"
}
