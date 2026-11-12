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
  discovery_hints = {
    organization       = var.organization_name
    subscriptionId     = data.azurerm_client_config.current.subscription_id
    tenantId           = data.azurerm_client_config.current.tenant_id
    automationClientId = azurerm_user_assigned_identity.operational["automation"].client_id
  }
}

# Publish only after apply has created the trust and inspection grants. This
# sends identifiers, not an Azure bearer token and not proof of organization
# ownership. The backend independently verifies the pending authenticated CC.
resource "terraform_data" "discovery_registration" {
  count            = var.discovery_endpoint != null ? 1 : 0
  triggers_replace = [jsonencode(local.discovery_hints), var.discovery_endpoint]
  provisioner "local-exec" {
    interpreter = ["python3"]
    command     = "${path.module}/scripts/submit_hints.py"
    environment = {
      DISCOVERY_HINTS_JSON = jsonencode(local.discovery_hints)
      DISCOVERY_ENDPOINT   = var.discovery_endpoint
    }
  }
  depends_on = [
    azurerm_federated_identity_credential.automation,
    azurerm_federated_identity_credential.support,
    azurerm_role_assignment.identity_inspector,
    azurerm_role_assignment.policy_executor,
  ]
}
