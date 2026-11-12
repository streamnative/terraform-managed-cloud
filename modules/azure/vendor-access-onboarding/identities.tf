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

data "azurerm_client_config" "current" {}

locals {
  subscription_scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  # Keep Azure RG names <=90 characters, including a region and CE suffix.
  # The hashed namespace still binds the unshortened canonical organization in tags.
  namespace_key      = substr(sha256("${var.organization_name}/${var.environment}"), 0, 12)
  bootstrap_rg_name  = "sncloud-${var.organization_name}-manager-rg"
  workload_rg_prefix = "snce-${local.namespace_key}-"
  tags = {
    "sn-organization" = var.organization_name
    "sn-managed-by"   = "streamnative"
    "sn-environment"  = var.environment
    "sn-purpose"      = "onboarding"
  }
}

# First apply only: do not adopt reserved groups by name/tag. This is a read-only
# CLI check, not an atomic namespace lock; the installation race is a release gate.
resource "terraform_data" "namespace_claim" {
  triggers_replace = [local.subscription_scope, var.organization_name, var.environment, var.disposable_subscription_id]
  lifecycle {
    precondition {
      condition     = var.disposable_subscription_id == null ? true : var.disposable_subscription_id == data.azurerm_client_config.current.subscription_id
      error_message = "The acknowledged disposable subscription must equal the authenticated provider subscription."
    }
  }
  provisioner "local-exec" {
    interpreter = ["python3"]
    command     = "${path.module}/scripts/check_namespace.py"
    environment = {
      AZURE_SUBSCRIPTION_ID      = data.azurerm_client_config.current.subscription_id
      WORKLOAD_RG_PREFIX         = local.workload_rg_prefix
      RESERVED_GROUP_NAMES       = jsonencode([local.bootstrap_rg_name])
      REQUIRE_EMPTY_SUBSCRIPTION = tostring(var.disposable_subscription_id != null)
    }
  }
}

# Repeat the two exact group checks when a new target is introduced later.
resource "terraform_data" "fresh_target" {
  for_each         = var.verification_targets
  triggers_replace = [local.aks_ids[each.key], each.value.node_resource_group]
  provisioner "local-exec" {
    interpreter = ["python3"]
    command     = "${path.module}/scripts/check_namespace.py"
    environment = {
      AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
      WORKLOAD_RG_PREFIX    = ""
      RESERVED_GROUP_NAMES  = jsonencode([split("/", local.group_ids[each.key])[4], each.value.node_resource_group])
    }
  }
}

resource "azurerm_resource_group" "bootstrap" {
  name       = local.bootstrap_rg_name
  location   = var.bootstrap_location
  tags       = local.tags
  depends_on = [terraform_data.namespace_claim]
}

resource "azurerm_user_assigned_identity" "operational" {
  for_each            = toset(["automation", "support"])
  name                = "sncloud-${var.organization_name}-${each.key}"
  resource_group_name = azurerm_resource_group.bootstrap.name
  location            = azurerm_resource_group.bootstrap.location
  tags                = local.tags
}

resource "azurerm_federated_identity_credential" "automation" {
  for_each                  = local.automation_subjects[var.environment]
  name                      = each.key
  user_assigned_identity_id = azurerm_user_assigned_identity.operational["automation"].id
  audience                  = ["api://AzureADTokenExchange/${var.organization_name}"]
  issuer                    = "https://accounts.google.com"
  subject                   = each.value
}

resource "azurerm_federated_identity_credential" "support" {
  for_each                  = local.support_subjects[var.environment]
  name                      = each.key
  user_assigned_identity_id = azurerm_user_assigned_identity.operational["support"].id
  audience                  = ["api://AzureADTokenExchange/${var.organization_name}"]
  issuer                    = "https://accounts.google.com"
  subject                   = each.value
}

resource "azurerm_role_definition" "identity_inspector" {
  depends_on        = [terraform_data.namespace_claim]
  name              = "sn-${local.namespace_key}-identity-inspector"
  scope             = local.subscription_scope
  assignable_scopes = [local.subscription_scope]
  description       = "Read the two onboarding UAMIs and their federation metadata at exact identity scopes."
  permissions {
    actions = [
      "Microsoft.ManagedIdentity/userAssignedIdentities/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/read",
    ]
  }
}

resource "azurerm_role_assignment" "identity_inspector" {
  for_each                         = azurerm_user_assigned_identity.operational
  scope                            = each.value.id
  role_definition_id               = azurerm_role_definition.identity_inspector.role_definition_resource_id
  principal_id                     = azurerm_user_assigned_identity.operational["automation"].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
