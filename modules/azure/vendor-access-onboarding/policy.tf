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

locals {
  role_ids = {
    contributor = "b24988ac-6180-42a0-ab88-20f7382dd24c"
    reader      = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
    aks_admin   = "0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8"
    aks_user    = "4abbcc35-e782-43d8-92c5-2d3f1bd2253f"
  }
  group_ids = { for key, target in var.verification_targets : key =>
    "${local.subscription_scope}/resourceGroups/${local.workload_rg_prefix}${target.location}-${key}"
  }
  aks_ids = { for key, target in var.verification_targets : key =>
    "${local.group_ids[key]}/providers/Microsoft.ContainerService/managedClusters/${target.aks_name}"
  }
  # Keep resourceGroup() out of the evaluation path for every unrelated Azure resource.
  fixed_node_target_check = "contains(createArray(${join(", ", [for id in values(local.aks_ids) : "'${lower(id)}'"])}), toLower(string(field('id'))))"
  grants = merge(local.enable_policies ? {
    workload-contributor = { identity = "automation", role = "contributor", target = "workload" }
    workload-aks-admin   = { identity = "automation", role = "aks_admin", target = "workload" }
    workload-aks-user    = { identity = "support", role = "aks_user", target = "workload" }
    } : {}, var.enable_node_reader_verification ? {
    node-auto-reader    = { identity = "automation", role = "reader", target = "node" }
    node-support-reader = { identity = "support", role = "reader", target = "node" }
  } : {})
  shared_parameters = {
    organization   = { type = "String" }
    environment    = { type = "String" }
    workloadPrefix = { type = "String" }
  }
  fixed_workload_match = {
    allOf = [
      { field = "type", equals = "Microsoft.Resources/subscriptions/resourceGroups" },
      { field = "id", in = values(local.group_ids) },
      { field = "name", like = "[concat(parameters('workloadPrefix'), '*')]" },
      { field = "name", equals = "[concat(parameters('workloadPrefix'), field('location'), '-', field('tags[sn-ce]'))]" },
      { field = "tags[sn-organization]", equals = "[parameters('organization')]" },
      { field = "tags[sn-managed-by]", equals = "streamnative" },
      { field = "tags[sn-environment]", equals = "[parameters('environment')]" },
      { field = "tags[sn-ce]", exists = "true" },
      { field = "tags[sn-ce]", notEquals = "" },
    ]
  }
  # resourceGroup() refers to the AKS parent, not its node RG. nodeResourceGroup
  # is read from the AKS result after provisioning, never guessed as MC_*.
  fixed_node_match = {
    allOf = [
      { field = "type", equals = "Microsoft.ContainerService/managedClusters" },
      { anyOf = [for key, target in var.verification_targets : { allOf = [
        { field = "id", equals = local.aks_ids[key] },
        { field = "Microsoft.ContainerService/managedClusters/nodeResourceGroup", equals = target.node_resource_group }
      ] }] },
      { value = "[if(${local.node_target_check}, resourceGroup().name, '')]", like = "[concat(parameters('workloadPrefix'), '*')]" },
      { value = "[if(${local.node_target_check}, resourceGroup().name, '')]", equals = "[if(${local.node_target_check}, concat(parameters('workloadPrefix'), resourceGroup().location, '-', tryGet(coalesce(tryGet(resourceGroup(), 'tags'), createObject()), 'sn-ce')), '')]" },
      { value = "[if(${local.node_target_check}, tryGet(coalesce(tryGet(resourceGroup(), 'tags'), createObject()), 'sn-organization'), '')]", equals = "[parameters('organization')]" },
      { value = "[if(${local.node_target_check}, tryGet(coalesce(tryGet(resourceGroup(), 'tags'), createObject()), 'sn-managed-by'), '')]", equals = "streamnative" },
      { value = "[if(${local.node_target_check}, tryGet(coalesce(tryGet(resourceGroup(), 'tags'), createObject()), 'sn-environment'), '')]", equals = "[parameters('environment')]" },
      { value = "[if(${local.node_target_check}, empty(tryGet(coalesce(tryGet(resourceGroup(), 'tags'), createObject()), 'sn-ce')), true())]", equals = false },
    ]
  }

  grant_rules = { for key, grant in local.grants : key => templatefile("${path.module}/policies/dine.json.tftpl", {
    match_json                 = grant.target == "workload" ? jsonencode(local.workload_match) : jsonencode(local.node_match)
    target_resource_group_json = jsonencode(grant.target == "workload" ? "[field('name')]" : "[field('Microsoft.ContainerService/managedClusters/nodeResourceGroup')]")
    assignment_name_json = jsonencode(grant.target == "workload" ?
      "[guid(toLower(field('id')), parameters('principalId'), parameters('roleDefinitionId'))]" :
      "[guid(toLower(concat(subscription().id, '/resourceGroups/', field('Microsoft.ContainerService/managedClusters/nodeResourceGroup'))), parameters('principalId'), parameters('roleDefinitionId'))]"
    )
    existence_condition_json = jsonencode({
      allOf = [
        { field = "Microsoft.Authorization/roleAssignments/principalId", equals = "[parameters('principalId')]" },
        { field = "Microsoft.Authorization/roleAssignments/roleDefinitionId", equals = "[parameters('roleDefinitionId')]" },
        { field = "Microsoft.Authorization/roleAssignments/principalType", equals = "ServicePrincipal" },
      ]
    })
    role_definition_ids_json = jsonencode([azurerm_role_definition.policy_executor[0].role_definition_resource_id])
    deployment_json = jsonencode({
      properties = {
        mode = "Incremental"
        template = {
          "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
          contentVersion = "1.0.0.0"
          parameters = {
            principalId      = { type = "string" }
            roleDefinitionId = { type = "string" }
          }
          resources = [{
            type       = "Microsoft.Authorization/roleAssignments"
            apiVersion = "2022-04-01"
            name       = "[guid(toLower(resourceGroup().id), parameters('principalId'), parameters('roleDefinitionId'))]"
            properties = {
              principalId      = "[parameters('principalId')]"
              principalType    = "ServicePrincipal"
              roleDefinitionId = "[parameters('roleDefinitionId')]"
              description      = "Managed by the StreamNative onboarding verification policy."
            }
          }]
        }
        parameters = {
          principalId      = { value = "[parameters('principalId')]" }
          roleDefinitionId = { value = "[parameters('roleDefinitionId')]" }
        }
      }
    })
  }) }
}

resource "azurerm_role_definition" "policy_executor" {
  count             = local.enable_policies ? 1 : 0
  depends_on        = [terraform_data.namespace_claim]
  name              = "sn-${local.namespace_key}-policy-executor"
  scope             = local.subscription_scope
  assignable_scopes = [local.subscription_scope]
  permissions {
    actions = [
      "Microsoft.Resources/deployments/read",
      "Microsoft.Resources/deployments/write",
      "Microsoft.Resources/deployments/operations/read",
      "Microsoft.Resources/deployments/operationStatuses/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleDefinitions/read",
    ]
  }
}

resource "azurerm_policy_definition" "grant" {
  for_each     = local.grants
  depends_on   = [terraform_data.namespace_claim]
  name         = "sn-${local.namespace_key}-${each.key}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "SNIP-187 ${each.key} verification grant"
  parameters = jsonencode(merge(local.shared_parameters, {
    principalId      = { type = "String" }
    roleDefinitionId = { type = "String" }
    effect = {
      type          = "String"
      allowedValues = ["Disabled", "DeployIfNotExists"]
      defaultValue  = "Disabled"
    }
  }))
  policy_rule = local.grant_rules[each.key]
}

resource "azurerm_subscription_policy_assignment" "grant" {
  for_each             = local.grants
  name                 = "s187-${substr(local.namespace_key, 0, 8)}-${substr(sha256(each.key), 0, 7)}"
  subscription_id      = local.subscription_scope
  policy_definition_id = azurerm_policy_definition.grant[each.key].id
  location             = var.bootstrap_location
  enforce              = true
  identity { type = "SystemAssigned" }
  parameters = jsonencode({
    organization     = { value = var.organization_name }
    environment      = { value = var.environment }
    workloadPrefix   = { value = local.workload_rg_prefix }
    principalId      = { value = azurerm_user_assigned_identity.operational[each.value.identity].principal_id }
    roleDefinitionId = { value = "${local.subscription_scope}/providers/Microsoft.Authorization/roleDefinitions/${local.role_ids[each.value.role]}" }
    effect           = { value = "DeployIfNotExists" }
  })
  depends_on = [terraform_data.fresh_target]
}

resource "azurerm_role_assignment" "policy_executor" {
  for_each                         = local.grants
  scope                            = local.subscription_scope
  role_definition_id               = azurerm_role_definition.policy_executor[0].role_definition_resource_id
  principal_id                     = azurerm_subscription_policy_assignment.grant[each.key].identity[0].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
  condition_version                = "2.0"
  condition = trimspace(templatefile("${path.module}/policies/fixed-grant-condition.tftpl", {
    role_id      = local.role_ids[each.value.role]
    principal_id = azurerm_user_assigned_identity.operational[each.value.identity].principal_id
  }))
}
