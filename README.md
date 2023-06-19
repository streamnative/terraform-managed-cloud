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

Previous versions of these modules can be found in the following locations:
- [terraform-aws-cloud//modules/managed-cloud?ref=v2.5.0](https://github.com/streamnative/terraform-aws-cloud/tree/v2.5.0-alpha/modules/managed-cloud): This was the original location of the AWS vendor access module, which has been moved to this repository. The last version released to the Terraform Registry was `v2.5.0-alpha`.
- [https://github.com/streamnative/terraform-aws-managed-cloud](https://github.com/streamnative/terraform-aws-managed-cloud): This repository contains an older AWS vendor access module, which has been deprecated and is no longer in use.

## Modules
The modules are organized by Cloud Provider. For example, the AWS modules are in the `modules/aws` directory and the GCP modules (WIP) modules are in the `modules/gcp`, and so on.

## Quickstart

### Using AWS module

Run the following terraform file within your AWS profile:

```hcl
module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws?ref=v3.1.1"

  external_id = "<YOUR_SNCLOUD_ORG_ID>"
}
```

## Examples
Examples of the modules can be found in the `examples` directory.

Details on the modules themselves and their requirements can be found in their respective README files, contained in the `modules` directory.

## Upgrading from the old AWS modules
If you have used the previous version of the AWS vendor access module, your configuration should have looked something like this:

```hcl
module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-aws-cloud//modules/managed-cloud?ref=v2.5.0-alpha"

  external_id                     = "o-kxb4r"
  runtime_hosted_zone_allowed_ids = ["arn:aws:route53:::hostedzone/Z00048871IAX8IX9HGD0"]
  region                          = "us-west-2"
  use_runtime_policy              = true

}
```

Upgrading to this version of the module is quite simple, but does involve a few minor changes.

- The `source` URL has changed to `github.com/streamnative/terraform--managed-cloud//modules/aws?ref=v3.0.1` (note the tag reference, which as of this writing is `v3.0.1`).
- `use_runtime_policy` has been removed, as it is now the default behavior.
- `runtime_hosted_zone_allowed_ids` has been renamed to `hosted_zone_allowed_ids`, and it now properly accepts a list of IDs for your hosted zones, rather than the full ARNs.

With these changes in mind, your configuration should now look like this:

```hcl
module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws?ref=v3.0.1"

  external_id             = "o-kxb4r"
  hosted_zone_allowed_ids = ["Z00048871IAX8IX9HGD0"]
  region                  = "us-west-2"

}
```

After making changes to your configuration, you can run `terraform init` to download the new module, and then `terraform apply` to apply the changes. 

In most cases, you will see the module wanting to change 7 resources (the total number of resources created by this module, if `use_runtime_policy` was set to `true`).

Most of the changes are in the IAM policies, which allow for compatability with the [v3.0.0 release](https://github.com/streamnative/terraform-aws-cloud/pull/91) of the `terraform-aws-cloud` module (this Terraform module is used for creating a StreamNative Cloud EKS environment).

If you have questions or concerns with these changes, please reach out to your StreamNative account representative.
