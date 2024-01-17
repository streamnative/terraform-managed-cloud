<!--
  ~ Copyright 2023 StreamNative, Inc.
  ~
  ~ Licensed under the Apache License, Version 2.0 (the "License");
  ~ you may not use this file except in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~     http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing, software
  ~ distributed under the License is distributed on an "AS IS" BASIS,
  ~ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~ See the License for the specific language governing permissions and
  ~ limitations under the License.
-->

# StreamNative Cloud - Azure Cloud Manger Module

This Terraform module creates Microsoft Entra Application Registrations and related service principals within your Azure subscription & Microsoft Entra ID. These resources give StreamNative access only for the provisioning and management of StreamNative's Managed Cloud offering.

For more information about StreamNative and our managed offerings for Apache Pulsar, visit our [website](https://streamnative.io/streamnativecloud/).

## Module Overview

This module creates the following resources:

- Microsoft Entra Application Registration `automation` for StreamNative Managed Cloud resources
  - Service Principal for `automation` Application Registration
  - Access configuration for `automation` Application Registration
- Microsoft Entra Application Registration `support` for StreamNative Managed Cloud resources
  - Service Principal for `support` Application Registration
  - Access configuration for `support` Application Registration

## Usage

To use this module you must have [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli) and be [familiar](https://developer.hashicorp.com/terraform/tutorials/azure-get-started) with its usage for Azure. It is recommended to securely store the Terraform configuration you create in source control, as well as use [Terraform's Remote State](https://www.terraform.io/language/state/remote) for storing the `*.tfstate` file.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | < 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.83.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.sn_automation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_federated_identity_credential.sn_support](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_resource_group.manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_user_assigned_identity.sn_automation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.sn_support](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to be added to the resources created by this module. | `map(any)` | `{}` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | The location of the resource group where the cloud manager IAMs will be created | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the cloud manager IAMs will be created | `string` | `""` | no |
| <a name="input_streamnative_automation_gsa_ids"></a> [streamnative\_automation\_gsa\_ids](#input\_streamnative\_automation\_gsa\_ids) | The GSAs will be used to provisioning StreamnNative cloud. | `map(string)` | `null` | no |
| <a name="input_streamnative_cloud_env"></a> [streamnative\_cloud\_env](#input\_streamnative\_cloud\_env) | The environment of StreamNative Cloud, used for all resources created by the module, e.g. "production", "staging", "test". | `string` | `"production"` | no |
| <a name="input_streamnative_org_id"></a> [streamnative\_org\_id](#input\_streamnative\_org\_id) | Your Organization ID within StreamNative Cloud, used for all resources created by the module. This will be the organization ID in the StreamNative console, e.g. "o-xhopj". | `string` | n/a | yes |
| <a name="input_streamnative_support_access_gsa_ids"></a> [streamnative\_support\_access\_gsa\_ids](#input\_streamnative\_support\_access\_gsa\_ids) | The GSA will be used by StreamnNative support team. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group where the cloud manager IAMs will be created |
| <a name="output_sn_automation_client_id"></a> [sn\_automation\_client\_id](#output\_sn\_automation\_client\_id) | The client ID of the sn automation service principal for StreamNative Cloud automation |
| <a name="output_sn_automation_principal_id"></a> [sn\_automation\_principal\_id](#output\_sn\_automation\_principal\_id) | The principal ID of the sn automation service principal for StreamNative Cloud automation |
| <a name="output_sn_support_client_id"></a> [sn\_support\_client\_id](#output\_sn\_support\_client\_id) | The client ID of the sn support service principal for StreamNative Cloud support access |
| <a name="output_sn_support_principal_id"></a> [sn\_support\_principal\_id](#output\_sn\_support\_principal\_id) | The principal ID of the sn support service principal for StreamNative Cloud support access |
