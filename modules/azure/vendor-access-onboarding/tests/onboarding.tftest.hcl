# All runs are mock plans. Never change command to apply: terraform_data has
# real local-exec provisioners even when the Azure provider is mocked.
mock_provider "azurerm" {
  override_during = plan
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "11111111-1111-4111-8111-111111111111"
      tenant_id       = "22222222-2222-4222-8222-222222222222"
      object_id       = "33333333-3333-4333-8333-333333333333"
      client_id       = "44444444-4444-4444-8444-444444444444"
    }
  }
  mock_resource "azurerm_resource_group" {
    defaults = { id = "/subscriptions/11111111-1111-4111-8111-111111111111/resourceGroups/sncloud-o-poc-manager-rg" }
  }
  mock_resource "azurerm_role_definition" {
    defaults = { role_definition_resource_id = "/subscriptions/11111111-1111-4111-8111-111111111111/providers/Microsoft.Authorization/roleDefinitions/55555555-5555-4555-8555-555555555555" }
  }
  mock_resource "azurerm_policy_definition" {
    defaults = { id = "/subscriptions/11111111-1111-4111-8111-111111111111/providers/Microsoft.Authorization/policyDefinitions/mock" }
  }
  mock_resource "azurerm_subscription_policy_assignment" {
    defaults = { identity = { principal_id = "66666666-6666-4666-8666-666666666666", tenant_id = "22222222-2222-4222-8222-222222222222" } }
  }
  override_resource {
    target = azurerm_user_assigned_identity.operational["automation"]
    values = {
      id           = "/subscriptions/11111111-1111-4111-8111-111111111111/resourceGroups/sncloud-o-poc-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-poc-automation"
      client_id    = "77777777-7777-4777-8777-777777777777"
      principal_id = "88888888-8888-4888-8888-888888888888"
    }
  }
  override_resource {
    target = azurerm_user_assigned_identity.operational["support"]
    values = {
      id           = "/subscriptions/11111111-1111-4111-8111-111111111111/resourceGroups/sncloud-o-poc-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-poc-support"
      client_id    = "99999999-9999-4999-8999-999999999999"
      principal_id = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"
    }
  }
}

run "one_input" {
  command = plan
  variables { organization_name = "o-poc" }
  assert {
    condition     = length(azurerm_role_assignment.identity_inspector) == 2 && length(azurerm_role_assignment.policy_executor) == 0 && length(azurerm_role_definition.policy_executor) == 0 && length(azurerm_policy_definition.grant) == 0 && length(terraform_data.discovery_registration) == 0 && length(azurerm_subscription_policy_assignment.disposable_rg_guard) == 0 && length(azurerm_role_assignment.disposable_rg_creator) == 0 && length(azurerm_role_assignment.caller_read_comparator) == 0
    error_message = "Default installation should create the two identity-scoped grants and no policy executors or receiver."
  }
  assert {
    condition     = toset(keys(output.discovery_hint)) == toset(["organization", "tenantId", "subscriptionId", "automationClientId"]) && output.discovery_hint.organization == "o-poc"
    error_message = "The discovery contract must contain exactly the four nonsecret hints."
  }
  assert {
    condition     = length(azurerm_role_definition.workload_rbac_manager) == 0 && length(azurerm_role_definition.full_ce_metadata_reader) == 0 && length(azurerm_role_definition.support_provider_metadata_reader) == 0 && output.workload_rbac_contract == null
    error_message = "The single-input default must not grant workload RBAC delegation or full-CE metadata access."
  }
}
run "known_workload_targets" {
  command = plan
  variables {
    organization_name = "o-poc"
    environment       = "test"
    verification_targets = {
      ce1 = { location = "eastus", aks_name = "aks-ce1", node_resource_group = "nodes-ce1" }
      ce2 = { location = "eastus", aks_name = "aks-ce2", node_resource_group = "nodes-ce2" }
    }
    discovery_endpoint = "http://127.0.0.1:8765/v1/azure-discovery/hints"
  }
  assert {
    condition     = length(azurerm_subscription_policy_assignment.grant) == 3 && length(terraform_data.discovery_registration) == 1 && toset(local.workload_match.allOf[1].in) == toset(values(output.workload_contract.workload_group_ids))
    error_message = "The verifier should publish the hint and install only three workload policies for the specified groups."
  }
}
run "caller_dependent_node_policies" {
  command = plan
  variables {
    organization_name = "o-poc"
    environment       = "test"
    verification_targets = {
      ce1 = { location = "eastus", aks_name = "aks-ce1", node_resource_group = "nodes-ce1" }
      ce2 = { location = "eastus", aks_name = "aks-ce2", node_resource_group = "nodes-ce2" }
    }
    enable_node_reader_verification = true
  }
  assert {
    condition = length(azurerm_role_assignment.policy_executor) == 5 && length(azurerm_role_definition.policy_executor) == 1 && length(local.node_match.allOf[1].anyOf) == 2 && alltrue([
      for i, key in ["ce1", "ce2"] : local.node_match.allOf[1].anyOf[i].allOf[0].equals == local.aks_ids[key] && local.node_match.allOf[1].anyOf[i].allOf[1].equals == var.verification_targets[key].node_resource_group
    ])
    error_message = "The two extra policies must bind actual AKS IDs to the corresponding node RGs."
  }
  assert {
    condition = alltrue([for key, grant in azurerm_role_assignment.policy_executor :
      strcontains(grant.condition, azurerm_user_assigned_identity.operational[local.grants[key].identity].principal_id) && strcontains(grant.condition, local.role_ids[local.grants[key].role]) && !strcontains(grant.condition, "roleAssignments/delete")
    ]) && !contains(one(azurerm_role_definition.policy_executor[0].permissions).actions, "Microsoft.Authorization/roleAssignments/delete")
    error_message = "The executor can write only its fixed principal and role and has no delete action."
  }
}
run "reject_production_policy_targets" {
  command = plan
  variables {
    organization_name    = "o-poc"
    verification_targets = { ce1 = { location = "eastus", aks_name = "aks-ce1", node_resource_group = "nodes-ce1" } }
  }
  expect_failures = [var.verification_targets]
}
run "reject_unsafe_hint_url" {
  command = plan
  variables {
    organization_name  = "o-poc"
    discovery_endpoint = "http://public.example/v1/azure-discovery/hints"
  }
  expect_failures = [var.discovery_endpoint]
}
run "uid_workload_contract" {
  command = plan
  variables {
    organization_name = "o-poc"
    environment       = "test"
    verification_targets = {
      "983ff00a-fe0f-4922-bdda-a01819504c35" = { location = "eastus", aks_name = "aks-test", node_resource_group = "nodes-test" }
    }
  }
  assert {
    condition     = output.workload_contract.workload_group_ids["983ff00a-fe0f-4922-bdda-a01819504c35"] == "/subscriptions/11111111-1111-4111-8111-111111111111/resourceGroups/snce-${substr(sha256("o-poc/test"), 0, 12)}-eastus-983ff00a-fe0f-4922-bdda-a01819504c35" && output.workload_contract.ce_key_tag == "sn-ce"
    error_message = "The group ID and sn-ce tag must use the CE UID used by the control plane."
  }
}

run "future_ce_without_predeclared_ids" {
  command = plan
  variables {
    organization_name          = "o-poc"
    environment                = "test"
    disposable_subscription_id = "11111111-1111-4111-8111-111111111111"
  }
  assert {
    condition     = length(azurerm_subscription_policy_assignment.grant) == 3 && length(local.group_ids) == 0 && length(terraform_data.fresh_target) == 0 && output.workload_contract.profile == "disposable-future-ce"
    error_message = "Future CE policies must not need an installer-supplied CE UID or per-target provisioner."
  }
  assert {
    condition     = length(azurerm_subscription_policy_assignment.disposable_rg_guard) == 1 && jsondecode(azurerm_policy_definition.disposable_rg_guard[0].policy_rule).then.effect == "Deny" && toset(one(azurerm_role_definition.disposable_rg_creator[0].permissions).actions) == toset(["Microsoft.Resources/subscriptions/resourceGroups/read", "Microsoft.Resources/subscriptions/resourceGroups/write"]) && length(azurerm_role_assignment.caller_read_comparator) == 0
    error_message = "RG write requires the guard and must not silently include IAM reads, delete or wider privileges."
  }
  assert {
    condition     = length([for c in local.workload_match.allOf : c if try(c.field == "id", false)]) == 0 && local.workload_match.allOf[1].equals == "eastus"
    error_message = "The future workload matcher must be region-bound and independent of a predeclared resource ID."
  }
}
run "future_ce_node_caller_read_comparator" {
  command = plan
  variables {
    organization_name                             = "o-poc"
    environment                                   = "test"
    disposable_subscription_id                    = "11111111-1111-4111-8111-111111111111"
    enable_node_reader_verification               = true
    enable_caller_role_assignment_read_comparator = true
  }
  assert {
    condition     = length(azurerm_subscription_policy_assignment.grant) == 5 && toset(one(azurerm_role_definition.caller_read_comparator[0].permissions).actions) == toset(["Microsoft.Authorization/roleAssignments/read"]) && azurerm_role_assignment.caller_read_comparator[0].principal_id == azurerm_user_assigned_identity.operational["automation"].principal_id
    error_message = "The comparator must grant only role-assignment metadata reads to automation."
  }
  assert {
    condition     = strcontains(local.node_match.allOf[2].value, "field('Microsoft.ContainerService/managedClusters/nodeResourceGroup')") && strcontains(local.node_match.allOf[2].value, "concat('MC_', resourceGroup().name, '_')")
    error_message = "Node policies must use AKS's actual output and reject node RGs outside the current parent namespace."
  }
}
run "reject_wrong_disposable_subscription" {
  command = plan
  variables {
    organization_name          = "o-poc"
    environment                = "test"
    disposable_subscription_id = "12345678-1234-1234-1234-123456789abc"
  }
  expect_failures = [terraform_data.namespace_claim]
}
run "reject_mixed_verification_profiles" {
  command = plan
  variables {
    organization_name          = "o-poc"
    environment                = "test"
    disposable_subscription_id = "11111111-1111-4111-8111-111111111111"
    verification_targets       = { ce1 = { location = "eastus", aks_name = "aks-ce1", node_resource_group = "nodes-ce1" } }
  }
  expect_failures = [var.disposable_subscription_id]
}
run "reject_shared_subscription_comparator" {
  command = plan
  variables {
    organization_name                             = "o-poc"
    environment                                   = "test"
    verification_targets                          = { ce1 = { location = "eastus", aks_name = "aks-ce1", node_resource_group = "nodes-ce1" } }
    enable_node_reader_verification               = true
    enable_caller_role_assignment_read_comparator = true
  }
  expect_failures = [var.enable_caller_role_assignment_read_comparator]
}
run "reject_non_test_future_profile" {
  command = plan
  variables {
    organization_name          = "o-poc"
    disposable_subscription_id = "11111111-1111-4111-8111-111111111111"
  }
  expect_failures = [var.disposable_subscription_id]
}

run "future_policy_expression_boundaries" {
  command = plan
  variables {
    organization_name               = "o-poc"
    environment                     = "test"
    disposable_subscription_id      = "11111111-1111-4111-8111-111111111111"
    enable_node_reader_verification = true
  }
  assert {
    condition     = !strcontains(azurerm_policy_definition.disposable_rg_guard[0].policy_rule, "resourceGroup()") && !strcontains(jsonencode(local.workload_match), "resourceGroup()") && jsondecode(azurerm_policy_definition.disposable_rg_guard[0].policy_rule).if.allOf[0].field == "type" && jsondecode(azurerm_policy_definition.disposable_rg_guard[0].policy_rule).if.allOf[0].equals == "Microsoft.Resources/subscriptions/resourceGroups"
    error_message = "The subscription RG guard must not evaluate resourceGroup() for non-RG resources."
  }
  assert {
    condition     = alltrue([for c in local.node_match.allOf : startswith(c.value, "[if(${local.node_target_check},") if try(strcontains(c.value, "resourceGroup()"), false)]) && strcontains(local.node_target_check, "equals(toLower(string(field('type'))), 'microsoft.containerservice/managedclusters')") && strcontains(local.node_target_check, "startsWith(toLower(string(field('id')))")
    error_message = "Every node parent lookup must be inside a lazy if guarded by the AKS type and reserved ID prefix."
  }
  assert {
    condition     = alltrue([for c in local.workload_match.allOf : strcontains(c.value, "coalesce(field('tags[sn-ce]'), '')") if try(strcontains(c.value, "replace("), false)]) && length([for c in local.workload_match.allOf : c if try(c.field == "tags[sn-ce]" && c.exists == "true", false)]) == 1 && length([for c in local.workload_match.allOf : c if try(c.field == "tags[sn-ce]" && c.notEquals == "", false)]) == 1
    error_message = "Missing CE tags must be handled safely and cannot satisfy the workload selector."
  }
  assert {
    condition     = jsondecode(azurerm_policy_definition.grant["node-auto-reader"].policy_rule).then.details.resourceGroupName == "[field('Microsoft.ContainerService/managedClusters/nodeResourceGroup')]" && jsondecode(azurerm_policy_definition.grant["workload-contributor"].policy_rule).if == local.workload_match
    error_message = "Rendered DINE rules must use the checked selector and actual node output."
  }
}

run "full_ce_scoped_workload_rbac" {
  command = plan
  variables {
    organization_name                             = "o-poc"
    environment                                   = "test"
    disposable_subscription_id                    = "11111111-1111-4111-8111-111111111111"
    enable_node_reader_verification               = true
    enable_caller_role_assignment_read_comparator = true
    enable_full_ce_workload_rbac                  = true
  }
  assert {
    condition     = length(azurerm_subscription_policy_assignment.grant) == 6 && length(azurerm_role_definition.workload_rbac_manager) == 1 && length(local.group_ids) == 0 && output.workload_contract.full_ce_workload_rbac
    error_message = "Full CE needs four workload grants and two node grants without any predeclared CE UID."
  }
  assert {
    condition = toset(one(azurerm_role_definition.workload_rbac_manager[0].permissions).actions) == toset([
      "Microsoft.Authorization/roleAssignments/read", "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete", "Microsoft.Authorization/roleDefinitions/read",
    ]) && length(coalesce(one(azurerm_role_definition.workload_rbac_manager[0].permissions).data_actions, [])) == 0
    error_message = "The delegated role must contain assignment lifecycle actions only, with no role definition write or data-plane actions."
  }
  assert {
    condition = toset(values(local.service_role_ids)) == toset([
      "4d97b98b-1d4f-4787-a291-c67834d212e7", "befefa01-2a29-4197-83a8-272ff33ce314",
      "acdd72a7-3385-48ef-bd42-f606fba81ae7",
    ]) && !contains(values(local.service_role_ids), local.workload_manager_role_id) && !contains(values(local.service_role_ids), local.role_ids.contributor)
    error_message = "Only the three reviewed service roles can be delegated; never Contributor or the assignment manager itself."
  }
  assert {
    condition = alltrue([for pair in [{ action = "write", attribute = "Request" }, { action = "delete", attribute = "Resource" }] :
      strcontains(local.workload_rbac_condition, "!(ActionMatches{'Microsoft.Authorization/roleAssignments/${pair.action}'})") &&
      strcontains(local.workload_rbac_condition, "@${pair.attribute}[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${join(", ", sort(values(local.service_role_ids)))}}") &&
      strcontains(local.workload_rbac_condition, "AND @${pair.attribute}[Microsoft.Authorization/roleAssignments:PrincipalType] StringEqualsIgnoreCase 'ServicePrincipal'") &&
      strcontains(local.workload_rbac_condition, "AND !(@${pair.attribute}[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {88888888-8888-4888-8888-888888888888, aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa})")
    ]) && strcontains(local.workload_rbac_condition, ")) AND ((")
    error_message = "Both writes and deletes must require the role allowlist and ServicePrincipal, and exclude automation/support with negated any-of equality."
  }
  assert {
    condition = (
      jsondecode(azurerm_policy_definition.grant["workload-rbac-manager"].policy_rule).if == local.workload_match &&
      jsondecode(azurerm_policy_definition.grant["workload-rbac-manager"].policy_rule).then.details.resourceGroupName == "[field('name')]" &&
      jsondecode(azurerm_policy_definition.grant["workload-rbac-manager"].policy_rule).then.details.deploymentScope == "ResourceGroup" &&
      jsondecode(azurerm_policy_definition.grant["workload-rbac-manager"].policy_rule).then.details.deployment.properties.template.resources[0].properties.condition == local.workload_rbac_condition &&
      jsondecode(azurerm_policy_definition.grant["workload-rbac-manager"].policy_rule).then.details.deployment.properties.template.resources[0].properties.conditionVersion == "2.0"
    )
    error_message = "DINE must install the conditioned manager at the matched workload RG, never at subscription scope."
  }
  assert {
    condition = alltrue([for attribute in ["condition", "conditionVersion"] :
      length([for c in jsondecode(azurerm_policy_definition.grant["workload-rbac-manager"].policy_rule).then.details.existenceCondition.allOf : c if c.field == "Microsoft.Authorization/roleAssignments/${attribute}" && c.equals == (attribute == "condition" ? local.workload_rbac_condition : "2.0")]) == 1
    ])
    error_message = "An existing assignment with missing or changed conditions must not satisfy policy compliance."
  }
  assert {
    condition = (
      strcontains(azurerm_role_assignment.policy_executor["workload-rbac-manager"].condition, local.workload_manager_role_id) &&
      strcontains(azurerm_role_assignment.policy_executor["workload-rbac-manager"].condition, "88888888-8888-4888-8888-888888888888") &&
      !strcontains(azurerm_role_assignment.policy_executor["workload-rbac-manager"].condition, "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa") &&
      !contains(one(azurerm_role_definition.policy_executor[0].permissions).actions, "Microsoft.Authorization/roleAssignments/delete")
    )
    error_message = "The separate policy executor can grant only the manager role to automation and has no role-assignment delete action."
  }
  assert {
    condition = (
      azurerm_role_definition.workload_rbac_manager[0].role_definition_id == local.workload_manager_role_id &&
      toset(one(azurerm_role_definition.full_ce_metadata_reader[0].permissions).actions) == toset(["Microsoft.Resources/subscriptions/read", "Microsoft.Resources/subscriptions/providers/read", "Microsoft.Authorization/roleDefinitions/read"]) &&
      toset(one(azurerm_role_definition.caller_read_comparator[0].permissions).actions) == toset(["Microsoft.Authorization/roleAssignments/read"]) &&
      azurerm_role_assignment.full_ce_metadata_reader[0].principal_id == "88888888-8888-4888-8888-888888888888" &&
      toset(one(azurerm_role_definition.support_provider_metadata_reader[0].permissions).actions) == toset(["Microsoft.Resources/subscriptions/providers/read"]) &&
      azurerm_role_assignment.support_provider_metadata_reader[0].principal_id == "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"
    )
    error_message = "Role IDs must be stable, with separate minimal automation/support metadata reads and unchanged comparator permissions."
  }
}

run "reject_full_ce_without_disposable_profile" {
  command = plan
  variables {
    organization_name            = "o-poc"
    enable_full_ce_workload_rbac = true
  }
  expect_failures = [var.enable_full_ce_workload_rbac]
}
run "reject_full_ce_without_node_reader" {
  command = plan
  variables {
    organization_name            = "o-poc"
    environment                  = "test"
    disposable_subscription_id   = "11111111-1111-4111-8111-111111111111"
    enable_full_ce_workload_rbac = true
  }
  expect_failures = [var.enable_full_ce_workload_rbac]
}
run "reject_full_ce_without_caller_metadata" {
  command = plan
  variables {
    organization_name               = "o-poc"
    environment                     = "test"
    disposable_subscription_id      = "11111111-1111-4111-8111-111111111111"
    enable_node_reader_verification = true
    enable_full_ce_workload_rbac    = true
  }
  expect_failures = [var.enable_full_ce_workload_rbac]
}
