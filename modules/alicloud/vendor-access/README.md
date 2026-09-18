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

## Upgrade existing deployments for ACK cluster tag updates

The vendor-access policy includes `cs:ModifyClusterTags` in the existing ACK
allow statement with `Resource: "*"`, matching the other ACK management actions.
This allows tags to be added or backfilled on existing clusters.

Existing customers must apply the updated vendor-access module before retrying
provisioning; upgrading the provisioning workflow alone does not update RAM:

1. In the Terraform configuration and state that manage vendor access, update the
   module source `ref` to a release or commit containing this fix. If following
   `main`, refresh the cached module with `terraform init -upgrade` as well.
2. Run `terraform init -upgrade`, then `terraform plan -out=vendor-access.tfplan`
   using the customer's RAM administration credentials. Review the plan for
   in-place policy document updates to `streamnative-bootstrap` and
   `streamnative-support`, which share this template. Role and attachment
   replacement is not required by this change.
3. Apply the reviewed plan with `terraform apply vendor-access.tfplan`.
4. Retry provisioning with a fresh assumed-role session after RAM propagation.

The pinned Alibaba Cloud provider updates each policy by creating a new default
RAM policy version. The existing
`DeleteOldestNonDefaultVersionWhenLimitExceeded` rotation strategy removes the
oldest non-default version if the version limit is reached. Policy names and
attachments stay the same; the JSON policy language `Version` remains `"1"`.
There is no separate module policy-version input to bump. The fix is distributed
through the repository's normal release process.

### Regression verification

For an end-to-end check in an approved test environment:

1. Use an existing ACK cluster managed by `alicloud_cs_managed_kubernetes.ack`
   and the updated CloudConnection assumed role. Record the cluster ID and tags.
2. Add `Project=PULSAR` and `Type=INFRA` through `additional_tags`, preserving
   existing tags. Confirm the plan shows an in-place `ack.tags` update with no
   cluster replacement.
3. Apply and verify the same cluster ID has the new tags, with no
   `403 StatusForbidden` for `cs:ModifyClusterTags`.
4. Run the full, untargeted `provision2` plan/apply and verify credential reads
   and remaining resources complete. If a targeted cluster update was needed
   for recovery, it is not a substitute for this full verification.
5. Restore the original tags through Terraform and verify the in-place update
   succeeds again.

## Execute following commands to import existing roles and policies if you lost the tfstate
```bash
terraform import module.vendor_access.alicloud_ram_policy.cloud_manager_access streamnative-bootstrap
terraform import  module.vendor_access.alicloud_ram_policy.support_access streamnative-support
terraform import module.vendor_access.alicloud_ram_role.cloud_manager_role streamnative-bootstrap
terraform import module.vendor_access.alicloud_ram_role.support_role streamnative-support
terraform import module.vendor_access.alicloud_ram_role_policy_attachment.cloud_manager_access role:streamnative-bootstrap:Custom:streamnative-bootstrap
terraform import module.vendor_access.alicloud_ram_role_policy_attachment.support_access role:streamnative-support:Custom:streamnative-support
```

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
