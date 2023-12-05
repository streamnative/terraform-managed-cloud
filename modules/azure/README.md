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

# StreamNative Cloud - Managed Azure Vendor Access

This Terraform module creates Azure resource group and related managed identity within your Azure subscription. These resources give StreamNative access only for the provisioning and management of StreamNative's Managed Cloud offering.

For more information about StreamNative and our managed offerings for Apache Pulsar, visit our [website](https://streamnative.io/streamnativecloud/).

## Module Overview

This module creates the following resources:

- Azure Resource Group for management and access control (per subscription, can be shared across multiple clusters)
  - DNS zone
  - Managed Identity
  - Custom Role
- Azure Resource Group for StreamNative Managed Cloud resources (per Pulsar Cluster)
  - Access configuration for Managed Identity

## Usage

To use this module you must have [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli) and be [familiar](https://developer.hashicorp.com/terraform/tutorials/azure-get-started) with its usage for Azure. It is recommended to securely store the Terraform configuration you create in source control, as well as use [Terraform's Remote State](https://www.terraform.io/language/state/remote) for storing the `*.tfstate` file.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
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
| [azurerm_dns_zone.sn_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |
| [azurerm_federated_identity_credential.sn_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_resource_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.sn_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_user_access_administrator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.sn_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.velero_backup_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_user_assigned_identity.sn_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to be added to the resources created by this module. | `map(any)` | `{}` | no |
| <a name="input_aks_resource_group_location"></a> [aks\_resource\_group\_location](#input\_aks\_resource\_group\_location) | The location of the resource group where the AKS cluster will be created | `string` | n/a | yes |
| <a name="input_aks_resource_group_name"></a> [aks\_resource\_group\_name](#input\_aks\_resource\_group\_name) | The name of the resource group where the AKS cluster will be created | `string` | n/a | yes |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | The name of the DNS zone to create for the management resources, if provided | `string` | `null` | no |
| <a name="input_management_managed_identity_name"></a> [management\_managed\_identity\_name](#input\_management\_managed\_identity\_name) | The name of the managed identity to create for the management resources | `string` | `"streamnative-cloud-manager"` | no |
| <a name="input_management_resource_group_location"></a> [management\_resource\_group\_location](#input\_management\_resource\_group\_location) | The location of the resource group where the management resources will be created | `string` | `"eastus"` | no |
| <a name="input_management_resource_group_name"></a> [management\_resource\_group\_name](#input\_management\_resource\_group\_name) | The name of the resource group where the management resources will be created | `string` | `"rg-streamnative-cloud-manager"` | no |
| <a name="input_streamnative_external_id"></a> [streamnative\_external\_id](#input\_streamnative\_external\_id) | An external ID that correspond to your Organization within StreamNative Cloud, used for all managed identities created by the module. This will be the organization ID in the StreamNative console, e.g. "o-xhopj". | `string` | n/a | yes |
| <a name="input_streamnative_support_access_gsa_ids"></a> [streamnative\_support\_access\_gsa\_ids](#input\_streamnative\_support\_access\_gsa\_ids) | The GSA will be used by StreamnNative support team. | `map(string)` | <pre>{<br>  "cloud_support_general": "103182365501883681520"<br>}</pre> | no |
| <a name="input_streamnative_vendor_access_gsa_ids"></a> [streamnative\_vendor\_access\_gsa\_ids](#input\_streamnative\_vendor\_access\_gsa\_ids) | The GSA will be used by StreamnNative cloud. | `map(string)` | <pre>{<br>  "cloud_manager": "103687585001802233900",<br>  "pool_automation": "101134291802756860252"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_resource_group_name"></a> [aks\_resource\_group\_name](#output\_aks\_resource\_group\_name) | The name of the resource group where the AKS cluster will be created |
| <a name="output_management_managed_identity_name"></a> [management\_managed\_identity\_name](#output\_management\_managed\_identity\_name) | The name of the managed identity to create for the management resources |
| <a name="output_management_resource_group_location"></a> [management\_resource\_group\_location](#output\_management\_resource\_group\_location) | The location of the resource group where the management resources will be created |
| <a name="output_management_resource_group_name"></a> [management\_resource\_group\_name](#output\_management\_resource\_group\_name) | The name of the resource group where the management resources will be created |
| <a name="output_sn_access_client_id"></a> [sn\_access\_client\_id](#output\_sn\_access\_client\_id) | The client ID of the managed identity to create for the management resources |
| <a name="output_sn_access_principal_id"></a> [sn\_access\_principal\_id](#output\_sn\_access\_principal\_id) | The principal ID of the managed identity to create for the management resources |
| <a name="output_sn_access_tenant_id"></a> [sn\_access\_tenant\_id](#output\_sn\_access\_tenant\_id) | The tenant ID of the managed identity to create for the management resources |
| <a name="output_streamnative_external_id"></a> [streamnative\_external\_id](#output\_streamnative\_external\_id) | An external ID that correspond to your Organization within StreamNative Cloud, used for all managed identities created by the module. This will be the organization ID in the StreamNative console, e.g. "o-xhopj". |

