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
    condition     = length(azurerm_role_assignment.identity_inspector) == 2 && length(azurerm_role_assignment.policy_executor) == 0 && length(azurerm_role_definition.policy_executor) == 0 && length(azurerm_policy_definition.grant) == 0 && length(terraform_data.discovery_registration) == 0
    error_message = "Default installation should create the two identity-scoped grants and no policy executors or receiver."
  }
  assert {
    condition     = toset(keys(output.discovery_hint)) == toset(["organization", "tenantId", "subscriptionId", "automationClientId"]) && output.discovery_hint.organization == "o-poc"
    error_message = "The discovery contract must contain exactly the four nonsecret hints."
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
