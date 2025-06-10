# StreamNative Cloud - Managed AliCloud Vendor Access

This Terraform module creates RAM resources within your AliCloud international account. These resources give StreamNative access only for the provisioning and management of StreamNative's BYOC(Bring Your Own Cloud) offering.

For more information about StreamNative and our managed offerings for Apache Pulsar, visit our [website](https://streamnative.io/streamnativecloud/).

# Quick Start

## Pre Requisites

To use this module you must have [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli) and be familiar with its usage for [AliCloud](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs#authentication). It is recommended to securely store the Terraform configuration you create in source control, as well as use [Terraform's Remote State](https://www.terraform.io/language/state/remote) for storing the `*.tfstate` file.

## Example

```hcl
provider "alicloud" {
  region = "<region>"
}

module "vendor_access" {
  source          = "github.com/streamnative/terraform-managed-cloud//modules/alicloud/vendor-access?ref=main"

  organization_ids = ["<your-streamnative-cloud-organization-id>"]
}
```

After [authenticating to your AliCloud international account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs#authentication) execute the following sequence of commands from the directory containing the `main.tf` configuration file:

1. Run `terraform init`
2. Run `terraform plan`
3. Run `terraform apply`

# Terraform Docs

## Requirements

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="requirement_alicloud"></a> [alicloud](#requirement_alicloud) | 1.248.0 |

## Providers

| Name                                                            | Version |
| --------------------------------------------------------------- | ------- |
| <a name="provider_alicloud"></a> [alicloud](#provider_alicloud) | 1.248.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                     | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [alicloud_ram_policy.cloud_manager_access](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/ram_policy)                                 | resource    |
| [alicloud_ram_policy.support_access](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/ram_policy)                                       | resource    |
| [alicloud_ram_role.cloud_manager_role](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/ram_role)                                       | resource    |
| [alicloud_ram_role.support_role](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/ram_role)                                             | resource    |
| [alicloud_ram_role_policy_attachment.cloud_manager_access](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/ram_role_policy_attachment) | resource    |
| [alicloud_ram_role_policy_attachment.support_access](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/resources/ram_role_policy_attachment)       | resource    |
| [alicloud_ack_service.open](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/data-sources/ack_service)                                            | data source |
| [alicloud_caller_identity.current](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/data-sources/caller_identity)                                 | data source |
| [alicloud_oss_service.open](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/data-sources/oss_service)                                            | data source |
| [alicloud_ram_policy_document.cloud_manager_trust_policy](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/data-sources/ram_policy_document)      | data source |
| [alicloud_ram_policy_document.support_role_trust_policy](https://registry.terraform.io/providers/hashicorp/alicloud/1.248.0/docs/data-sources/ram_policy_document)       | data source |

## Inputs

| Name                                                                                                                                          | Description                                                                                                             | Type           | Default                                                                | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | -------------- | ---------------------------------------------------------------------- | :------: |
| <a name="input_organization_ids"></a> [organization_ids](#input_organization_ids)                                                             | The ID of your organization on StreamNative Cloud.                                                                      | `list(string)` | n/a                                                                    |   yes    |
| <a name="input_region"></a> [region](#input_region)                                                                                           | The aliyun region where your StreamNative Cloud Environment can be deployed. Defaults to all regions.                   | `string`       | `"*"`                                                                  |    no    |
| <a name="input_streamnative_cloud_manager_role_arns"></a> [streamnative_cloud_manager_role_arns](#input_streamnative_cloud_manager_role_arns) | The list of StreamNative cloud manager role ARNs. This is used to grant StreamNative cloud manager to your environment. | `list(string)` | <pre>[<br> "acs:ram::5855446584058772:role/cloud-manager"<br>]</pre>   |    no    |
| <a name="input_streamnative_support_role_arns"></a> [streamnative_support_role_arns](#input_streamnative_support_role_arns)                   | The list of StreamNative support role ARNs. This is used to grant StreamNative support to your environment.             | `list(string)` | <pre>[<br> "acs:ram::5855446584058772:role/support-general"<br>]</pre> |    no    |

## Outputs

| Name                                                                                | Description |
| ----------------------------------------------------------------------------------- | ----------- |
| <a name="output_account_id"></a> [account_id](#output_account_id)                   | n/a         |
| <a name="output_organization_ids"></a> [organization_ids](#output_organization_ids) | n/a         |
| <a name="output_services"></a> [services](#output_services)                         | n/a         |
