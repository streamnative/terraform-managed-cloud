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

# StreamNative Managed Cloud
This repository contains Terraform modules for the management of StreamNative's vendor access to a Cloud Provider.

## Modules
The modules are organized by Cloud Provider. For example, the AWS modules are in the `modules/aws` directory and the GCP modules are in the `modules/gcp`, and for Azure the modules are in the `modules/azure` directory.

More detailed documentation can be viewed in the respective module directory.

## Quickstart

### Using AWS module

Run the following terraform file within your AWS profile:

<!-- x-release-please-start-version -->
```hcl
provider "aws" {
  region = <YOUR_REGION>
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws/vendor-access?ref=v3.23.1"

  external_id = "<YOUR_SNCLOUD_ORG_ID>"
}
```
<!-- x-release-please-end -->

### Using GCP module

Run the following terraform file within your GCP credentials:

<!-- x-release-please-start-version -->
```hcl
provider "google" {
  project = "<YOUR_PROJECT>"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/vendor-access?ref=v3.23.1"

  project = "<YOUR_PROJECT>"
  streamnative_org_id = "<YOUR_SNCLOUD_ORG_ID>"
}
```
<!-- x-release-please-end -->

### Using Azure module

Run the following terraform file within your Azure credentials:

<!-- x-release-please-start-version -->
```hcl
provider "azurerm" {
  features {

  }
}

provider "azuread" {}

module "sn_cloud_manager" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/sn-cloud-manager?ref=v3.23.1"

  streamnative_org_id     = "<YOUR_SNCLOUD_ORG_ID>"
  resource_group_location = "<RESOURCE_GROUP_LOCATION>"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/vendor-access?ref=v3.23.1"

  streamnative_org_id     = "<YOUR_SNCLOUD_ORG_ID>"
  resource_group_name     = "<RESOURCE_GROUP_NAME>"
  resource_group_location = "<RESOURCE_GROUP_LOCATION>"

  sn_automation_principal_id = module.sn_cloud_manager.sn_automation_principal_id
  sn_automation_client_id = module.sn_cloud_manager.sn_automation_client_id
  sn_support_principal_id = module.sn_cloud_manager.sn_support_principal_id
  sn_support_client_id = module.sn_cloud_manager.sn_support_client_id

  depends_on = [
    module.sn_cloud_manager
  ]
}

output "subscription_id" {
  value       = module.sn_managed_cloud.subscription_id
  description = "The subscription ID of the AKS cluster"
}

output "tenant_id" {
  value       = module.sn_managed_cloud.tenant_id
  description = "The tenant ID of the AKS cluster"
}

output "client_id" {
  value       = module.sn_managed_cloud.sn_automation_client_id
  description = "The client ID of the sn automation service principal for StreamNative Cloud automation"
}

output "support_client_id" {
  value       = module.sn_managed_cloud.sn_support_client_id
  description = "The client ID of the sn support service principal for StreamNative Cloud support access"
}

output "resource_group_name" {
  value       = module.sn_managed_cloud.resource_group_name
  description = "The name of the resource group where the AKS cluster will be created"
}
```
<!-- x-release-please-end -->

## Examples
Examples of the modules can be found in the `examples` directory.

Details on the modules themselves and their requirements can be found in their respective README files, contained in the `modules` directory.
