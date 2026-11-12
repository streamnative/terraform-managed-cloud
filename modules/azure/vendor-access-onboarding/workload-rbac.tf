# The installer owns these definitions. Automation can assign only the listed
# service roles at a policy-selected CE RG or descendant, never redefine roles.
locals {
  workload_role_namespace  = "https://streamnative.io/azure/onboarding/${data.azurerm_client_config.current.subscription_id}/${local.namespace_key}"
  workload_manager_role_id = uuidv5("url", "${local.workload_role_namespace}/workload-rbac-manager")
  service_role_ids = {
    network_contributor  = "4d97b98b-1d4f-4787-a291-c67834d212e7"
    dns_zone_contributor = "befefa01-2a29-4197-83a8-272ff33ce314"
    reader               = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
  }
  workload_rbac_condition = trimspace(templatefile("${path.module}/policies/workload-rbac-condition.tftpl", {
    role_ids = join(", ", sort(values(local.service_role_ids)))
    excluded_principal_ids = join(", ", sort([
      lower(azurerm_user_assigned_identity.operational["automation"].principal_id),
      lower(azurerm_user_assigned_identity.operational["support"].principal_id),
    ]))
  }))
}

resource "azurerm_role_definition" "workload_rbac_manager" {
  count              = var.enable_full_ce_workload_rbac ? 1 : 0
  depends_on         = [terraform_data.namespace_claim]
  role_definition_id = local.workload_manager_role_id
  name               = "sn-${local.namespace_key}-workload-rbac-manager"
  scope              = local.subscription_scope
  assignable_scopes  = [local.subscription_scope]
  description        = "CE-scoped assignment management; every grant must carry the installer workload role/principal condition."
  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete",
      "Microsoft.Authorization/roleDefinitions/read",
    ]
  }
}

# Data-source lookups are scoped at the subscription endpoint, even though the
# resulting service assignments remain at the CE RG or one of its children.
resource "azurerm_role_definition" "full_ce_metadata_reader" {
  count             = var.enable_full_ce_workload_rbac ? 1 : 0
  depends_on        = [terraform_data.namespace_claim]
  name              = "sn-${local.namespace_key}-full-ce-metadata-reader"
  scope             = local.subscription_scope
  assignable_scopes = [local.subscription_scope]
  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/read",
      "Microsoft.Resources/subscriptions/providers/read",
      "Microsoft.Authorization/roleDefinitions/read",
    ]
  }
}

resource "azurerm_role_assignment" "full_ce_metadata_reader" {
  count                            = var.enable_full_ce_workload_rbac ? 1 : 0
  scope                            = local.subscription_scope
  role_definition_id               = azurerm_role_definition.full_ce_metadata_reader[0].role_definition_resource_id
  principal_id                     = azurerm_user_assigned_identity.operational["automation"].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
  depends_on                       = [azurerm_subscription_policy_assignment.disposable_rg_guard]
}

# The support AzureRM alias also enumerates provider metadata during initialize,
# even with registration disabled. It does not need automation's other reads.
resource "azurerm_role_definition" "support_provider_metadata_reader" {
  count             = var.enable_full_ce_workload_rbac ? 1 : 0
  depends_on        = [terraform_data.namespace_claim]
  name              = "sn-${local.namespace_key}-support-provider-metadata-reader"
  scope             = local.subscription_scope
  assignable_scopes = [local.subscription_scope]
  permissions {
    actions = ["Microsoft.Resources/subscriptions/providers/read"]
  }
}

resource "azurerm_role_assignment" "support_provider_metadata_reader" {
  count                            = var.enable_full_ce_workload_rbac ? 1 : 0
  scope                            = local.subscription_scope
  role_definition_id               = azurerm_role_definition.support_provider_metadata_reader[0].role_definition_resource_id
  principal_id                     = azurerm_user_assigned_identity.operational["support"].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
  depends_on                       = [azurerm_subscription_policy_assignment.disposable_rg_guard]
}
