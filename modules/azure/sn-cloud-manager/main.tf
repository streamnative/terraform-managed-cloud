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

data "azurerm_subscription" "current" {}

locals {
  tags = merge({
    "Vendor"                 = "StreamNative"
    "Service"                = "StreamNative Cloud"
    "StreamNativeCloudOrgID" = var.streamnative_org_id
  }, var.additional_tags)

  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : format("sncloud-%s-manager-rg", var.streamnative_org_id)
  default_automation_gsa_ids = {
    "test" : {
      cloud_manager_sncloud_test_iam_gserviceaccount_com         = "103687585001802233900",
      pool_automation_sncloud_test_iam_gserviceaccount_com       = "101134291802756860252",
      cloud_support_general_sncloud_test_iam_gserviceaccount_com = "103182365501883681520",
    },
    "staging" : {
      cloud_manager   = "100475141292983344285",
      pool_automation = "100556251728244561373",
    },
    "production" : {
      cloud_manager   = "108050666045451143798",
      pool_automation = "108029274547326196788",
    }
  }

  default_support_access_gsa_ids = {
    "test" : {
      cloud_support_general_sncloud_test_iam_gserviceaccount_com = "103182365501883681520",
    },
    "staging" : {
      cloud_support_general = "100434858314678442047",
    },
    "production" : {
      cloud_support_general = "105547309919970817091",
      cloud_support_china   = "118445804661219609076",
      cloud_support_eu      = "106226564917594611181",
      cloud_support_us      = "102988431238400117777",
    }
  }

  streamnative_automation_gsa_ids     = var.streamnative_automation_gsa_ids != null ? var.streamnative_automation_gsa_ids : local.default_automation_gsa_ids[var.streamnative_cloud_env]
  streamnative_support_access_gsa_ids = var.streamnative_support_access_gsa_ids != null ? var.streamnative_support_access_gsa_ids : local.default_support_access_gsa_ids[var.streamnative_cloud_env]
}

# Create a resource group for the SN Cloud manager
resource "azurerm_resource_group" "manager" {
  name     = local.resource_group_name
  location = var.resource_group_location
  tags     = local.tags
}

# Create the user-assigned managed identity for the SN Cloud automation access
resource "azurerm_user_assigned_identity" "sn_automation" {
  name                = format("sncloud-%s-automation", var.streamnative_org_id)
  resource_group_name = azurerm_resource_group.manager.name
  location            = azurerm_resource_group.manager.location
  tags                = local.tags
}

# Create the user-assigned managed identity for the SN Cloud support access
resource "azurerm_user_assigned_identity" "sn_support" {
  name                = format("sncloud-%s-support", var.streamnative_org_id)
  resource_group_name = azurerm_resource_group.manager.name
  location            = azurerm_resource_group.manager.location
  tags                = local.tags
}

# Create federated identity credentials for the SN Cloud automation access
resource "azurerm_federated_identity_credential" "sn_automation" {
  for_each            = local.streamnative_automation_gsa_ids
  resource_group_name = azurerm_resource_group.manager.name
  name                = each.key
  parent_id           = azurerm_user_assigned_identity.sn_automation.id
  audience            = [format("api://AzureADTokenExchange/%s", var.streamnative_org_id)]
  issuer              = "https://accounts.google.com"
  subject             = each.value
}

# Create federated identity credentials for the SN Cloud support access
resource "azurerm_federated_identity_credential" "sn_support" {
  for_each            = local.streamnative_support_access_gsa_ids
  resource_group_name = azurerm_resource_group.manager.name
  name                = each.key
  parent_id           = azurerm_user_assigned_identity.sn_support.id
  audience            = [format("api://AzureADTokenExchange/%s", var.streamnative_org_id)]
  issuer              = "https://accounts.google.com"
  subject             = each.value
}

# resource "azurerm_role_assignment" "subscription_rbac_admin" {
#   scope                = data.azurerm_subscription.current.id
#   role_definition_name = "Role Based Access Control Administrator"
#   principal_id         = azurerm_user_assigned_identity.sn_automation.principal_id

#   skip_service_principal_aad_check = true

#   condition_version = "2.0"
#   condition         = templatefile("${path.module}/role-assignment-condition.tpl", {})
# }

# resource "azuread_application_registration" "sn_automation" {
#   display_name = format("sncloud-%s-automation", var.streamnative_org_id)
#   description  = "The application registration for the StreamNative Cloud automation"

#   homepage_url          = "https://streamnative.io"
#   marketing_url         = "https://streamnative.io/streamnativecloud/"
#   privacy_statement_url = "https://streamnative.io/privacy"
#   terms_of_service_url  = "https://streamnative.io/terms"
#   support_url           = "https://support.streamnative.io/hc/en-us"
# }

# resource "azuread_application_registration" "sn_support" {
#   display_name = format("sncloud-%s-support", var.streamnative_org_id)
#   description  = "The application registration for the StreamNative Cloud support access"

#   homepage_url          = "https://streamnative.io"
#   marketing_url         = "https://streamnative.io/streamnativecloud/"
#   privacy_statement_url = "https://streamnative.io/privacy"
#   terms_of_service_url  = "https://streamnative.io/terms"
#   support_url           = "https://support.streamnative.io/hc/en-us"
# }

# resource "azuread_service_principal" "sn_automation" {
#   client_id                    = azuread_application_registration.sn_automation.client_id
#   app_role_assignment_required = false
#   use_existing                 = true
#   description                  = "The service principal for the StreamNative Cloud automation"
# }

# resource "azuread_service_principal" "sn_support" {
#   client_id                    = azuread_application_registration.sn_support.client_id
#   app_role_assignment_required = false
#   use_existing                 = true
#   description                  = "The service principal for the StreamNative Cloud support access"
# }

# resource "azuread_application_federated_identity_credential" "sn_automation" {
#   for_each       = var.streamnative_automation_gsa_ids
#   application_id = azuread_application_registration.sn_automation.id
#   display_name   = each.key
#   audiences      = [format("api://AzureADTokenExchange/%s", var.streamnative_org_id)]
#   issuer         = "https://accounts.google.com"
#   subject        = each.value
# }

# resource "azuread_application_federated_identity_credential" "sn_support" {
#   for_each       = var.streamnative_support_access_gsa_ids
#   application_id = azuread_application_registration.sn_support.id
#   display_name   = each.key
#   audiences      = [format("api://AzureADTokenExchange/%s", var.streamnative_org_id)]
#   issuer         = "https://accounts.google.com"
#   subject        = each.value
# }

# resource "azurerm_role_assignment" "subscription_rbac_admin" {
#   scope                = data.azurerm_subscription.current.id
#   role_definition_name = "Role Based Access Control Administrator"
#   principal_id         = azuread_service_principal.sn_automation.id

#   skip_service_principal_aad_check = true

#   condition_version = "2.0"
#   condition         = templatefile("${path.module}/role-assignment-condition.tpl", {})
# }

output "resource_group_name" {
  value       = azurerm_resource_group.manager.name
  description = "The name of the resource group where the cloud manager IAMs will be created"
}

output "sn_support_client_id" {
  value       = azurerm_user_assigned_identity.sn_support.client_id
  description = "The client ID of the sn support service principal for StreamNative Cloud support access"
}

output "sn_support_principal_id" {
  value       = azurerm_user_assigned_identity.sn_support.principal_id
  description = "The principal ID of the sn support service principal for StreamNative Cloud support access"
}

output "sn_automation_client_id" {
  value       = azurerm_user_assigned_identity.sn_automation.client_id
  description = "The client ID of the sn automation service principal for StreamNative Cloud automation"
}

output "sn_automation_principal_id" {
  value       = azurerm_user_assigned_identity.sn_automation.principal_id
  description = "The principal ID of the sn automation service principal for StreamNative Cloud automation"
}

output "subscription_id" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "The subscription ID of the AKS cluster"
}

output "tenant_id" {
  value       = data.azurerm_subscription.current.tenant_id
  description = "The tenant ID of the AKS cluster"
}
