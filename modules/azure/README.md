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

# StreamNative Managed Cloud on Azure

This repository contains Terraform modules for the management of StreamNative's vendor access to Azure.

There are two modules in this repository:

- [modules/azure/sn-cloud-manager](modules/azure/sn-cloud-manager): This module creates Microsoft Entra Application Registrations and related service principals within your Azure subscription & Microsoft Entra ID. These resources give StreamNative access only for the provisioning and management of StreamNative's Managed Cloud offering.
- [modules/azure/vendor-access](modules/azure/vendor-access): This module creates an Azure Resource Group within your Azure subscription. The module also helps to configure the role assignments for the StreamNative Managed Cloud service principals created by `sn-cloud-manager` module.

## Quickstart

### Pre-requisites
To use this module you must have [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli) and be [familiar](https://developer.hashicorp.com/terraform/tutorials/azure-get-started) with its usage for Azure. It is recommended to securely store the Terraform configuration you create in source control, as well as use [Terraform's Remote State](https://www.terraform.io/language/state/remote) for storing the `*.tfstate` file.

### Using `sn-cloud-manager` module

For each Microsoft Entra ID, you will need to run this module once to create the `automation` and `support` Application Registrations and related service principals. Below is an example of how to use this module:

```hcl
provider "azurerm" {
  features {

  }
}

provider "azuread" {}

module "azure-sn-cloud-manager" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/sn-cloud-manager?ref=master"

  streamnative_cloud_env = "test" # or staging, production
  resource_group_location = "westus2"
  streamnative_org_id = "o-12345"
}
```

### Using `vendor-access` module

For each AKS cluster, you will need to run this module once to create the Azure Resource Group and configure the role assignments for the StreamNative Managed Cloud service principals. Below is an example of how to use this module:

```hcl
provider "azurerm" {
  features {

  }
}

provider "azuread" {}

module "azure-managed-cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/vendor-access?ref=master"

  resource_group_name     = "azure-westus2-aks-test"
  resource_group_location = "westus2"

  streamnative_org_id = "o-12345"

  sn_automation_principal_id = xxxx
  sn_support_principal_id = xxxx
  sn_automation_client_id = xxxx
  sn_support_client_id = xxxx
}
```

### Using `sn-cloud-manager` and `vendor-access` modules together

Below is an example of how to use both modules together:

```hcl
provider "azurerm" {
  features {

  }
}

provider "azuread" {}

module "azure-sn-cloud-manager" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/sn-cloud-manager?ref=main"

  streamnative_cloud_env = "test" # or staging, production
  resource_group_location = "westus2"
  streamnative_org_id = "o-12345"
}

module "azure-managed-cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/vendor-access?ref=main"

  resource_group_name     = "azure-westus2-aks-test"
  resource_group_location = "westus2"

  streamnative_org_id = "o-12345"

  sn_automation_principal_id = module.azure-sn-cloud-manager.sn_automation_principal_id
  sn_support_principal_id = module.azure-sn-cloud-manager.sn_support_principal_id
  sn_automation_client_id = module.azure-sn-cloud-manager.sn_automation_client_id
  sn_support_client_id = module.azure-sn-cloud-manager.sn_support_client_id
}
```

To run the example, execute the following commands:

```shell
terraform init
terraform plan
terraform apply
```
