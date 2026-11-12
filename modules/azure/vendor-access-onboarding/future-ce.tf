# This experiment is intentionally unavailable in the default and shared-subscription profiles.
# Azure RBAC cannot restrict resourceGroups/write by RG name. The Deny policy
# constrains every caller in the EMPTY disposable subscription, including its installer.
locals {
  future_ce       = var.disposable_subscription_id != null
  enable_policies = local.future_ce || length(var.verification_targets) > 0
  future_workload_match = {
    allOf = concat([
      { field = "type", equals = "Microsoft.Resources/subscriptions/resourceGroups" },
      { field = "location", equals = "eastus" },
      ], slice(local.fixed_workload_match.allOf, 2, length(local.fixed_workload_match.allOf)), [
      { field = "tags[sn-ce]", match = "........-....-....-....-............" },
      { value = "[length(replace(string(field('tags[sn-ce]')), '-', ''))]", equals = 32 },
      { value = "[replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(string(field('tags[sn-ce]')), '-', ''), '0', ''), '1', ''), '2', ''), '3', ''), '4', ''), '5', ''), '6', ''), '7', ''), '8', ''), '9', ''), 'a', ''), 'b', ''), 'c', ''), 'd', ''), 'e', ''), 'f', '')]", equals = "" },
    ])
  }
  future_node_target_check = "and(equals(toLower(string(field('type'))), 'microsoft.containerservice/managedclusters'), startsWith(toLower(string(field('id'))), toLower(concat(subscription().id, '/resourceGroups/', parameters('workloadPrefix')))))"
  node_target_check        = local.future_ce ? local.future_node_target_check : local.fixed_node_target_check
  # Target the actual returned nodeResourceGroup, while refusing names outside
  # AKS's MC_<parent>_* namespace. Never infer the target name from this prefix.
  future_node_match = {
    allOf = concat([
      { field = "type", equals = "Microsoft.ContainerService/managedClusters" },
      { field = "location", equals = "eastus" },
      { value = "[if(${local.node_target_check}, startsWith(toLower(string(field('Microsoft.ContainerService/managedClusters/nodeResourceGroup'))), toLower(concat('MC_', resourceGroup().name, '_'))), false())]", equals = true },
    ], slice(local.fixed_node_match.allOf, 2, length(local.fixed_node_match.allOf)))
  }
  # Encoding the branches avoids Terraform's object/tuple unification changing
  # the shape of the Azure policy rule or requiring fixed CE IDs in future mode.
  workload_match = jsondecode(local.future_ce ? jsonencode(local.future_workload_match) : jsonencode(local.fixed_workload_match))
  node_match     = jsondecode(local.future_ce ? jsonencode(local.future_node_match) : jsonencode(local.fixed_node_match))
}

resource "azurerm_policy_definition" "disposable_rg_guard" {
  count        = local.future_ce ? 1 : 0
  name         = "sn-${local.namespace_key}-disposable-rg-guard"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "SNIP-187 disposable subscription RG namespace guard"
  parameters   = jsonencode(local.shared_parameters)
  policy_rule = jsonencode({
    "if" = {
      allOf = [
        { field = "type", equals = "Microsoft.Resources/subscriptions/resourceGroups" },
        { "not" = { anyOf = [
          { field = "name", equals = local.bootstrap_rg_name },
          local.future_workload_match,
          { allOf = [
            { field = "name", like = "MC_${local.workload_rg_prefix}eastus-*" },
            { field = "location", equals = "eastus" },
          ] },
        ] } },
      ]
    }
    then = { effect = "Deny" }
  })
}

resource "azurerm_subscription_policy_assignment" "disposable_rg_guard" {
  count                = local.future_ce ? 1 : 0
  name                 = "s187-${local.namespace_key}-guard"
  subscription_id      = local.subscription_scope
  policy_definition_id = azurerm_policy_definition.disposable_rg_guard[0].id
  enforce              = true
  parameters = jsonencode({
    organization   = { value = var.organization_name }
    environment    = { value = var.environment }
    workloadPrefix = { value = local.workload_rg_prefix }
  })
  depends_on = [azurerm_resource_group.bootstrap]
}

resource "azurerm_role_definition" "disposable_rg_creator" {
  count             = local.future_ce ? 1 : 0
  name              = "sn-${local.namespace_key}-disposable-rg-creator"
  scope             = local.subscription_scope
  assignable_scopes = [local.subscription_scope]
  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/write",
    ]
  }
}

resource "azurerm_role_assignment" "disposable_rg_creator" {
  count                            = local.future_ce ? 1 : 0
  scope                            = local.subscription_scope
  role_definition_id               = azurerm_role_definition.disposable_rg_creator[0].role_definition_resource_id
  principal_id                     = azurerm_user_assigned_identity.operational["automation"].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
  depends_on                       = [azurerm_subscription_policy_assignment.disposable_rg_guard]
}

resource "azurerm_role_definition" "caller_read_comparator" {
  count             = var.enable_caller_role_assignment_read_comparator ? 1 : 0
  name              = "sn-${local.namespace_key}-caller-read-comparator"
  scope             = local.subscription_scope
  assignable_scopes = [local.subscription_scope]
  permissions {
    actions = ["Microsoft.Authorization/roleAssignments/read"]
  }
}

resource "azurerm_role_assignment" "caller_read_comparator" {
  count                            = var.enable_caller_role_assignment_read_comparator ? 1 : 0
  scope                            = local.subscription_scope
  role_definition_id               = azurerm_role_definition.caller_read_comparator[0].role_definition_resource_id
  principal_id                     = azurerm_user_assigned_identity.operational["automation"].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
  depends_on                       = [azurerm_subscription_policy_assignment.disposable_rg_guard]
}
