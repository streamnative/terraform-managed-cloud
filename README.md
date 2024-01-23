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

```hcl
module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws?ref=<LATEST_GIT_TAG>"

  external_id = "<YOUR_SNCLOUD_ORG_ID>"
}
```

### Using GCP module

Run the following terraform file within your GCP credentials:

```hcl
provider "google" {
  project = "<YOUR_PROJECT>"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/gcp/vendor-access?ref=<LATEST_GIT_TAG>"
  project = "<YOUR_PROJECT>"
}
```

### Using Asure module

Run the following terraform file within your Azure credentials:

```hcl
provider "azurerm" {
  features {

  }
}

provider "azuread" {}

module "azure_sn_cloud_manager" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/sn-cloud-manager?ref=<LATEST_GIT_TAG>"

  resource_group_location = "<RESOURCE_GROUP_LOCATION>"
  streamnative_org_id = "<YOUR_SNCLOUD_ORG_ID>"
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/vendor-access?ref=<LATEST_GIT_TAG>"

  resource_group_name     = "<RESOURCE_GROUP_NAME>"
  resource_group_location = "<RESOURCE_GROUP_LOCATION>"

  streamnative_org_id = "<YOUR_SNCLOUD_ORG_ID>"

  depends_on = [
    module.azure-sn-cloud-manager
  ]
}
```

## Examples
Examples of the modules can be found in the `examples` directory.

Details on the modules themselves and their requirements can be found in their respective README files, contained in the `modules` directory.
