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
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/sn-cloud-manager?ref=main"

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
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/vendor-access?ref=main"

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
  streamnative_org_id = "o-123456"
}

module "azure-managed-cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/azure/vendor-access?ref=main"

  resource_group_name     = "azure-westus2-aks-test"
  resource_group_location = "westus2"

  streamnative_org_id = "o-123456"

  sn_automation_principal_id = module.azure-sn-cloud-manager.sn_automation_principal_id
  sn_support_principal_id = module.azure-sn-cloud-manager.sn_support_principal_id
  sn_automation_client_id = module.azure-sn-cloud-manager.sn_automation_client_id
  sn_support_client_id = module.azure-sn-cloud-manager.sn_support_client_id

  depends_on = [
    module.azure-sn-cloud-manager
  ]
}

output "client_id" {
  value       = module.azure-managed-cloud.sn_automation_client_id
  description = "The client ID of the sn automation service principal for StreamNative Cloud automation"
}

output "support_client_id" {
  value       = module.azure-managed-cloud.sn_support_client_id
  description = "The client ID of the sn support service principal for StreamNative Cloud support access"
}

output "subscription_id" {
  value       = module.azure-managed-cloud.subscription_id
  description = "The subscription ID of the AKS cluster"
}

output "tenant_id" {
  value       = module.azure-managed-cloud.tenant_id
  description = "The tenant ID of the AKS cluster"
}

output "resource_group_name" {
  value       = module.azure-managed-cloud.resource_group_name
  description = "The name of the resource group where the AKS cluster will be created"
}
```

To run the example, execute the following commands:

1. `terraform init`

<details><summary>(example output)</summary><p>

```
$ terraform init

Initializing the backend...
Initializing modules...
Downloading git::https://github.com/streamnative/terraform-managed-cloud.git?ref=v3.11.1 for azure-managed-cloud...
- azure-managed-cloud in .terraform/modules/azure-managed-cloud/modules/azure/vendor-access
Downloading git::https://github.com/streamnative/terraform-managed-cloud.git?ref=v3.11.1 for azure-sn-cloud-manager...
- azure-sn-cloud-manager in .terraform/modules/azure-sn-cloud-manager/modules/azure/sn-cloud-manager

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "< 4.0.0"...
- Finding hashicorp/azuread versions matching "< 3.0.0"...
- Installing hashicorp/azurerm v3.90.0...
- Installed hashicorp/azurerm v3.90.0 (signed by HashiCorp)
- Installing hashicorp/azuread v2.47.0...
- Installed hashicorp/azuread v2.47.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
</p></details>

2. `terraform plan`

<details><summary>(example output)</summary><p>

```
$ terraform plan
module.azure-sn-cloud-manager.data.azurerm_subscription.current: Reading...
module.azure-sn-cloud-manager.data.azurerm_subscription.current: Read complete after 1s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # module.azure-managed-cloud.data.azurerm_subscription.current will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "azurerm_subscription" "current" {
      + display_name          = (known after apply)
      + id                    = (known after apply)
      + location_placement_id = (known after apply)
      + quota_id              = (known after apply)
      + spending_limit        = (known after apply)
      + state                 = (known after apply)
      + subscription_id       = (known after apply)
      + tags                  = (known after apply)
      + tenant_id             = (known after apply)
    }

  # module.azure-managed-cloud.azurerm_resource_group.aks will be created
  + resource "azurerm_resource_group" "aks" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "azure-sn-cloud-cluster"
      + tags     = {
          + "Service"                = "StreamNative Cloud"
          + "StreamNativeCloudOrgID" = "o-123456"
          + "Vendor"                 = "StreamNative"
        }
    }

  # module.azure-managed-cloud.azurerm_role_assignment.sn_automation will be created
  + resource "azurerm_role_assignment" "sn_automation" {
      + id                               = (known after apply)
      + name                             = (known after apply)
      + principal_id                     = (known after apply)
      + principal_type                   = (known after apply)
      + role_definition_id               = (known after apply)
      + role_definition_name             = "Contributor"
      + scope                            = (known after apply)
      + skip_service_principal_aad_check = (known after apply)
    }

  # module.azure-managed-cloud.azurerm_role_assignment.sn_automation_cluster_admin will be created
  + resource "azurerm_role_assignment" "sn_automation_cluster_admin" {
      + id                               = (known after apply)
      + name                             = (known after apply)
      + principal_id                     = (known after apply)
      + principal_type                   = (known after apply)
      + role_definition_id               = (known after apply)
      + role_definition_name             = "Azure Kubernetes Service Cluster Admin Role"
      + scope                            = (known after apply)
      + skip_service_principal_aad_check = (known after apply)
    }

  # module.azure-managed-cloud.azurerm_role_assignment.sn_support will be created
  + resource "azurerm_role_assignment" "sn_support" {
      + id                               = (known after apply)
      + name                             = (known after apply)
      + principal_id                     = (known after apply)
      + principal_type                   = (known after apply)
      + role_definition_id               = (known after apply)
      + role_definition_name             = "Azure Kubernetes Service Cluster User Role"
      + scope                            = (known after apply)
      + skip_service_principal_aad_check = (known after apply)
    }

  # module.azure-managed-cloud.azurerm_role_assignment.user_access_administrator will be created
  + resource "azurerm_role_assignment" "user_access_administrator" {
      + condition                        = (known after apply)
      + condition_version                = "2.0"
      + id                               = (known after apply)
      + name                             = (known after apply)
      + principal_id                     = (known after apply)
      + principal_type                   = (known after apply)
      + role_definition_id               = (known after apply)
      + role_definition_name             = "Role Based Access Control Administrator"
      + scope                            = (known after apply)
      + skip_service_principal_aad_check = (known after apply)
    }

  # module.azure-managed-cloud.azurerm_role_definition.velero_backup_role will be created
  + resource "azurerm_role_definition" "velero_backup_role" {
      + assignable_scopes           = (known after apply)
      + description                 = "The role grants the minimum required permissions needed by Velero to perform backups, restores, and deletions. Reference: https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure?tab=readme-ov-file#specify-role"
      + id                          = (known after apply)
      + name                        = "azure-sn-cloud-cluster-VeleroBackupRole"
      + role_definition_id          = (known after apply)
      + role_definition_resource_id = (known after apply)
      + scope                       = (known after apply)

      + permissions {
          + actions      = [
              + "Microsoft.Compute/disks/read",
              + "Microsoft.Compute/disks/write",
              + "Microsoft.Compute/disks/endGetAccess/action",
              + "Microsoft.Compute/disks/beginGetAccess/action",
              + "Microsoft.Compute/snapshots/read",
              + "Microsoft.Compute/snapshots/write",
              + "Microsoft.Compute/snapshots/delete",
              + "Microsoft.Storage/storageAccounts/listkeys/action",
              + "Microsoft.Storage/storageAccounts/regeneratekey/action",
              + "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
              + "Microsoft.Storage/storageAccounts/blobServices/containers/read",
              + "Microsoft.Storage/storageAccounts/blobServices/containers/write",
              + "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action",
              + "Microsoft.Storage/storageAccounts/read",
            ]
          + data_actions = [
              + "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action",
              + "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
              + "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
              + "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
              + "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
            ]
          + not_actions  = []
        }
    }

  # module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_automation["cloud_manager"] will be created
  + resource "azurerm_federated_identity_credential" "sn_automation" {
      + audience            = [
          + "api://AzureADTokenExchange/o-123456",
        ]
      + id                  = (known after apply)
      + issuer              = "https://accounts.google.com"
      + name                = "cloud_manager"
      + parent_id           = (known after apply)
      + resource_group_name = "sncloud-o-123456-manager-rg"
      + subject             = "******************"
    }

  # module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_automation["pool_automation"] will be created
  + resource "azurerm_federated_identity_credential" "sn_automation" {
      + audience            = [
          + "api://AzureADTokenExchange/o-123456",
        ]
      + id                  = (known after apply)
      + issuer              = "https://accounts.google.com"
      + name                = "pool_automation"
      + parent_id           = (known after apply)
      + resource_group_name = "sncloud-o-123456-manager-rg"
      + subject             = "******************"
    }

  # module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_china"] will be created
  + resource "azurerm_federated_identity_credential" "sn_support" {
      + audience            = [
          + "api://AzureADTokenExchange/o-123456",
        ]
      + id                  = (known after apply)
      + issuer              = "https://accounts.google.com"
      + name                = "cloud_support_china"
      + parent_id           = (known after apply)
      + resource_group_name = "sncloud-o-123456-manager-rg"
      + subject             = "******************"
    }

  # module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_eu"] will be created
  + resource "azurerm_federated_identity_credential" "sn_support" {
      + audience            = [
          + "api://AzureADTokenExchange/o-123456",
        ]
      + id                  = (known after apply)
      + issuer              = "https://accounts.google.com"
      + name                = "cloud_support_eu"
      + parent_id           = (known after apply)
      + resource_group_name = "sncloud-o-123456-manager-rg"
      + subject             = "******************"
    }

  # module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_general"] will be created
  + resource "azurerm_federated_identity_credential" "sn_support" {
      + audience            = [
          + "api://AzureADTokenExchange/o-123456",
        ]
      + id                  = (known after apply)
      + issuer              = "https://accounts.google.com"
      + name                = "cloud_support_general"
      + parent_id           = (known after apply)
      + resource_group_name = "sncloud-o-123456-manager-rg"
      + subject             = "******************"
    }

  # module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_us"] will be created
  + resource "azurerm_federated_identity_credential" "sn_support" {
      + audience            = [
          + "api://AzureADTokenExchange/o-123456",
        ]
      + id                  = (known after apply)
      + issuer              = "https://accounts.google.com"
      + name                = "cloud_support_us"
      + parent_id           = (known after apply)
      + resource_group_name = "sncloud-o-123456-manager-rg"
      + subject             = "******************"
    }

  # module.azure-sn-cloud-manager.azurerm_resource_group.manager will be created
  + resource "azurerm_resource_group" "manager" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "sncloud-o-123456-manager-rg"
      + tags     = {
          + "Service"                = "StreamNative Cloud"
          + "StreamNativeCloudOrgID" = "o-123456"
          + "Vendor"                 = "StreamNative"
        }
    }

  # module.azure-sn-cloud-manager.azurerm_user_assigned_identity.sn_automation will be created
  + resource "azurerm_user_assigned_identity" "sn_automation" {
      + client_id           = (known after apply)
      + id                  = (known after apply)
      + location            = "eastus"
      + name                = "sncloud-o-123456-automation"
      + principal_id        = (known after apply)
      + resource_group_name = "sncloud-o-123456-manager-rg"
      + tags                = {
          + "Service"                = "StreamNative Cloud"
          + "StreamNativeCloudOrgID" = "o-123456"
          + "Vendor"                 = "StreamNative"
        }
      + tenant_id           = (known after apply)
    }

  # module.azure-sn-cloud-manager.azurerm_user_assigned_identity.sn_support will be created
  + resource "azurerm_user_assigned_identity" "sn_support" {
      + client_id           = (known after apply)
      + id                  = (known after apply)
      + location            = "eastus"
      + name                = "sncloud-o-123456-support"
      + principal_id        = (known after apply)
      + resource_group_name = "sncloud-o-123456-manager-rg"
      + tags                = {
          + "Service"                = "StreamNative Cloud"
          + "StreamNativeCloudOrgID" = "o-123456"
          + "Vendor"                 = "StreamNative"
        }
      + tenant_id           = (known after apply)
    }

Plan: 15 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + additional_roles           = [
      + {
          + id   = (known after apply)
          + name = "azure-sn-cloud-cluster-VeleroBackupRole"
        },
    ]
  + resource_group_name        = "azure-sn-cloud-cluster"
  + sn_automation_client_id    = (known after apply)
  + sn_automation_principal_id = (known after apply)
  + sn_support_client_id       = (known after apply)
  + sn_support_principal_id    = (known after apply)
  + streamnative_org_id        = "o-123456"
  + subscription_id            = (known after apply)
  + tenant_id                  = (known after apply)

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
</p></details>

3. `terraform apply`

<details><summary>(example output)</summary><p>

```bash
terraform apply -auto-approve
module.azure-sn-cloud-manager.data.azurerm_subscription.current: Reading...
module.azure-sn-cloud-manager.data.azurerm_subscription.current: Read complete after 0s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx]
module.azure-sn-cloud-manager.azurerm_resource_group.manager: Creating...
module.azure-sn-cloud-manager.azurerm_resource_group.manager: Creation complete after 2s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sncloud-o-123456-manager-rg]
module.azure-sn-cloud-manager.azurerm_user_assigned_identity.sn_support: Creating...
module.azure-sn-cloud-manager.azurerm_user_assigned_identity.sn_automation: Creating...
module.azure-sn-cloud-manager.azurerm_user_assigned_identity.sn_support: Creation complete after 4s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sncloud-o-123456-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-123456-support]
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_china"]: Creating...
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_us"]: Creating...
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_eu"]: Creating...
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_general"]: Creating...
module.azure-sn-cloud-manager.azurerm_user_assigned_identity.sn_automation: Creation complete after 4s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sncloud-o-123456-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-123456-automation]
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_automation["cloud_manager"]: Creating...
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_automation["pool_automation"]: Creating...
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_eu"]: Creation complete after 4s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sncloud-o-123456-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-123456-support/federatedIdentityCredentials/cloud_support_eu]
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_automation["pool_automation"]: Creation complete after 4s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sncloud-o-123456-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-123456-automation/federatedIdentityCredentials/pool_automation]
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_general"]: Creation complete after 7s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sncloud-o-123456-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-123456-support/federatedIdentityCredentials/cloud_support_general]
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_automation["cloud_manager"]: Creation complete after 8s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sncloud-o-123456-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-123456-automation/federatedIdentityCredentials/cloud_manager]
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_us"]: Still creating... [10s elapsed]
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_china"]: Still creating... [10s elapsed]
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_china"]: Creation complete after 10s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sncloud-o-123456-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-123456-support/federatedIdentityCredentials/cloud_support_china]
module.azure-sn-cloud-manager.azurerm_federated_identity_credential.sn_support["cloud_support_us"]: Creation complete after 13s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/sncloud-o-123456-manager-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sncloud-o-123456-support/federatedIdentityCredentials/cloud_support_us]
module.azure-managed-cloud.data.azurerm_subscription.current: Reading...
module.azure-managed-cloud.azurerm_resource_group.aks: Creating...
module.azure-managed-cloud.data.azurerm_subscription.current: Read complete after 1s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx]
module.azure-managed-cloud.azurerm_resource_group.aks: Creation complete after 2s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/azure-sn-cloud-cluster]
module.azure-managed-cloud.azurerm_role_assignment.sn_automation_cluster_admin: Creating...
module.azure-managed-cloud.azurerm_role_definition.velero_backup_role: Creating...
module.azure-managed-cloud.azurerm_role_assignment.sn_automation: Creating...
module.azure-managed-cloud.azurerm_role_assignment.sn_support: Creating...
module.azure-managed-cloud.azurerm_role_definition.velero_backup_role: Creation complete after 4s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/providers/Microsoft.Authorization/roleDefinitions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx|/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/azure-sn-cloud-cluster]
module.azure-managed-cloud.azurerm_role_assignment.user_access_administrator: Creating...
module.azure-managed-cloud.azurerm_role_assignment.sn_automation_cluster_admin: Still creating... [10s elapsed]
module.azure-managed-cloud.azurerm_role_assignment.sn_automation: Still creating... [10s elapsed]
module.azure-managed-cloud.azurerm_role_assignment.sn_support: Still creating... [10s elapsed]
module.azure-managed-cloud.azurerm_role_assignment.user_access_administrator: Still creating... [10s elapsed]
module.azure-managed-cloud.azurerm_role_assignment.sn_automation: Still creating... [20s elapsed]
module.azure-managed-cloud.azurerm_role_assignment.sn_automation_cluster_admin: Still creating... [20s elapsed]
module.azure-managed-cloud.azurerm_role_assignment.sn_support: Still creating... [20s elapsed]
module.azure-managed-cloud.azurerm_role_assignment.user_access_administrator: Still creating... [20s elapsed]
module.azure-managed-cloud.azurerm_role_assignment.sn_automation: Creation complete after 25s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/azure-sn-cloud-cluster/providers/Microsoft.Authorization/roleAssignments/9a91a79d-9896-d706-3962-ad487d8ea5c7]
module.azure-managed-cloud.azurerm_role_assignment.sn_automation_cluster_admin: Creation complete after 26s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/azure-sn-cloud-cluster/providers/Microsoft.Authorization/roleAssignments/c5300ea8-ffe2-970e-65f5-e2d8781db316]
module.azure-managed-cloud.azurerm_role_assignment.sn_support: Creation complete after 26s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/azure-sn-cloud-cluster/providers/Microsoft.Authorization/roleAssignments/ee292874-8009-874f-8bdb-af00a2377275]
module.azure-managed-cloud.azurerm_role_assignment.user_access_administrator: Creation complete after 24s [id=/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/azure-sn-cloud-cluster/providers/Microsoft.Authorization/roleAssignments/bb99122c-c1df-4ce4-cdd5-417e62dea3f8]

Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

additional_roles = [
  {
    "id" = "/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/providers/Microsoft.Authorization/roleDefinitions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx|/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/azure-sn-cloud-cluster"
    "name" = "azure-sn-cloud-cluster-VeleroBackupRole"
  },
]
resource_group_name = "azure-sn-cloud-cluster"
sn_automation_client_id = "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
sn_automation_principal_id = "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
sn_support_client_id = "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
sn_support_principal_id = "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
streamnative_org_id = "o-123456"
subscription_id = "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
tenant_id = "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

</p></details>
