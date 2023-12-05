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

# Manage Azure Entra Applications and Service Principals

data "azuread_client_config" "current" {}

resource "azuread_application_registration" "sn_automation" {
  display_name = format("%s-automation", var.resource_group_name)
  description  = "The application registration for the StreamNative Cloud automation"

  homepage_url          = "https://streamnative.io"
  marketing_url         = "https://streamnative.io/streamnativecloud/"
  privacy_statement_url = "https://streamnative.io/privacy"
  terms_of_service_url  = "https://streamnative.io/terms"
  support_url           = "https://support.streamnative.io/hc/en-us"
}

resource "azuread_application_registration" "sn_support" {
  display_name = format("%s-support", var.resource_group_name)
  description  = "The application registration for the StreamNative Cloud support access"

  homepage_url          = "https://streamnative.io"
  marketing_url         = "https://streamnative.io/streamnativecloud/"
  privacy_statement_url = "https://streamnative.io/privacy"
  terms_of_service_url  = "https://streamnative.io/terms"
  support_url           = "https://support.streamnative.io/hc/en-us"
}

resource "azuread_application_federated_identity_credential" "sn_automation" {
  for_each       = var.streamnative_automation_gsa_ids
  application_id = azuread_application_registration.sn_automation.id
  display_name   = each.key
  audiences      = [format("api://AzureADTokenExchange/%s", var.streamnative_external_id)]
  issuer         = "https://accounts.google.com"
  subject        = each.value
}

resource "azuread_application_federated_identity_credential" "sn_support" {
  for_each       = var.streamnative_support_access_gsa_ids
  application_id = azuread_application_registration.sn_support.id
  display_name   = each.key
  audiences      = [format("api://AzureADTokenExchange/%s", var.streamnative_external_id)]
  issuer         = "https://accounts.google.com"
  subject        = each.value
}

resource "azuread_service_principal" "sn_automation" {
  client_id                    = azuread_application_registration.sn_automation.client_id
  app_role_assignment_required = false
  use_existing                 = true
  description                  = "The service principal for the StreamNative Cloud automation"
}

resource "azuread_service_principal" "sn_support" {
  client_id                    = azuread_application_registration.sn_support.client_id
  app_role_assignment_required = false
  use_existing                 = true
  description                  = "The service principal for the StreamNative Cloud support access"
}