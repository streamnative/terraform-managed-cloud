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

# StreamNative Cloud - Managed AWS Vendor Access
This Terraform module creates IAM resources within your AWS account. These resources give StreamNative access only for the provisioning and management of StreamNative's Managed Cloud offering.

For more information about StreamNative and our managed offerings for Apache Pulsar, visit our [website](https://streamnative.io/streamnativecloud/).

## Module Overview
This module creates the following resources within your AWS account:

- `StreamNativeCloudPermissionBoudary`: The [permission boundary](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html) defines the scope of possible AWS actions and resources StreamNative is authorized to perform and use within your AWS account.
  - It is self-enforcing and required for any IAM Role created by StreamNative
  - Sets which IAM policies and expected EKS cluster resources StreamNative is allowed to work with
  - Prevents privilege escalation

- `role/StreamNativeCloudManagementRole` & `role/StreamNativeCloudManagementPolicy`: These IAM resources are used for the day-to-day management of the StreamNative managed infrastructure in your AWS account. This role and policy have the following characteristics:
  - Limited in their ability to create, modify, and delete resources within AWS
  - Authorized to fully manage StreamNative owned EKS cluster, worker nodes, and load balancers

- `role/StreamNativeCloudBootstrapRole` & `policy/StreamNativeCloudBootstrapPolicy`: These IAM resources are used for provisioning, deprovisioning, and regular or emergency maintenance. This role and policy have the following characteristics:
  - Have the ability to create, delete, manage, and read (within the limits of the permission boundary) EC2, EKS, IAM, DynamoDB, Route53, and KMS resources
  - Cannot create or modify IAM policies (but are allowed to work with IAM policies specified by this module)
  - Can only work with resources that have specific tags associated or certain expected patterns in the resource's friendly name.

- `policy/StreamNativeCloudRuntimePolicy` & `policy/StreamNativeCloudLbPolicy`: These policies are needed by add-ons running within EKS that require an [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) for interacting with AWS services. The EKS add-ons we install include:
  - [aws-ebs-csi-driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver): Manages the lifecycle of EBS volumes used by Apache Pulsar running within EKS
  - [aws-load-balanacer-controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/): Used for managing external ingress resources within EKS, such as Network Load Balancers
  - [certificate-manager](https://github.com/cert-manager/cert-manager): Manages TLS certificates within the cluster, requiring Route53 access for validating domain ownership
  - [cluster-autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md): Examines and modifies EC2 autoscaling groups for the EKS cluster based on resource utilization
  - [external-dns](https://github.com/kubernetes-sigs/external-dns): Manages DNS records within EKS in a delegated Route53 Public Hosted Zone
  - [velero](https://github.com/vmware-tanzu/velero): Used for backups of Kubernetes resources and EBS volumes to S3

## Usage
To use this module you must have [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli) and be [familiar](https://learn.hashicorp.com/collections/terraform/aws-get-started) with its usage for AWS. It is recommended to securely store the Terraform configuration you create in source control, as well as use [Terraform's Remote State](https://www.terraform.io/language/state/remote) for storing the `*.tfstate` file.

### Pre Requisites
This module requires only one input to function:

- `external_id`: The [external ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html) that correspond to your [Organization ID](https://docs.streamnative.io/cloud/stable/concepts/concepts#organizations) within StreamNative Cloud. Our services use this ID for any [STS assume role calls](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) to IAM roles created by the module. To find your Organization ID(s), please refer to our [documentation](https://docs.streamnative.io/cloud/stable/use/organization).

### Optional Inputs

- `additional_iam_policy_arns`: A list of IAM policies within your AWS account that StreamNative is authorized to work with. Typically this is not required, but may be necessary if third party software (such as your own APM or monitoring tooling) is needed on the cluster.
  - Note: By default, our IAM roles can attach any IAM policy created under the `/StreamNative/` [IAM path](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#identifiers-friendly-names) with the default policies created by this module. If you need a custom policy, create one under the root path `/StreamNative/` and it will implicitly be made available for use without needing to specify this input.

### Get Started

Start by writing the following configuration to a new file `main.tf` containing the following Terraform code:

```hcl

provider "aws" {
  region = <YOUR_REGION>
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws/vendor-access?ref=<LATEST_GIT_TAG>"

  external_id = "<YOUR_SNCLOUD_ORG_ID>"
}
```

Or if using multiple orgs

```hcl

provider "aws" {
  region = <YOUR_REGION>
}

module "sn_managed_cloud" {
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws/vendor-access?ref=<LATEST_GIT_TAG>"

  external_ids = ["<YOUR_SNCLOUD_ORG_ID>", "<YOUR_SNCLOUD_ORG_ID>"]
}
```

After [authenticating to your AWS account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) execute the following sequence of commands from the directory containing the `main.tf` configuration file:

1. Run `terraform init`
2. Run `terraform plan`
3. Run `terraform apply`


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.32.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.4.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.alb_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.management_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.permission_boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.provision_1_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.provision_2_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.provision_preserve_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.runtime_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.bootstrap_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.management_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bootstrap_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.management_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.management_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.provision1_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.provision2_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.provision_preserve_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [local_file.alb_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.management_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.permission_boundary_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.provision1_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.provision2_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.provision_preserve_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.runtime_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.streamnative_bootstrap_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.streamnative_management_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.ebs_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_kms_key.s3_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_iam_policy_arns"></a> [additional\_iam\_policy\_arns](#input\_additional\_iam\_policy\_arns) | Provide a list of additional IAM policy arns allowed for use with iam:AttachRolePolicy, defined in the StreamNativePermissionBoundary. | `list(string)` | `[]` | no |
| <a name="input_create_bootstrap_role"></a> [create\_bootstrap\_role](#input\_create\_bootstrap\_role) | Whether or not to create the bootstrap role, which is used by StreamNative for the initial deployment of the StreamNative Cloud | `string` | `true` | no |
| <a name="input_ebs_kms_key_arns"></a> [ebs\_kms\_key\_arns](#input\_ebs\_kms\_key\_arns) | Sets the list of allowed kms key arns, if not set, uses the default ebs kms key | `list(any)` | `[]` | no |
| <a name="input_eks_cluster_pattern"></a> [eks\_cluster\_pattern](#input\_eks\_cluster\_pattern) | Defines the eks clsuter prefix for streamnative clusters. This should normally remain the default value. | `string` | `"*snc*"` | no |
| <a name="input_enforce_vendor_federation"></a> [enforce\_vendor\_federation](#input\_enforce\_vendor\_federation) | Do not enable this unless explicitly told to do so by StreamNative. Restrict access for the streamnative\_vendor\_access\_role\_arns to only federated Google accounts. Intended to be true by default in the future. | `bool` | `false` | no |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | A external ID that correspond to your Organization within StreamNative Cloud, used for all STS assume role calls to the IAM roles created by the module. This will be the organization ID in the StreamNative console, e.g. "o-xhopj". | `string` | `""` | no |
| <a name="input_external_ids"></a> [external\_ids](#input\_external\_ids) | A list of external IDs that correspond to your Organization within StreamNative Cloud, used for all STS assume role calls to the IAM roles created by the module. This will be the organization ID in the StreamNative console, e.g. "o-xhopj". | `list(string)` | `[]` | no |
| <a name="input_hosted_zone_allowed_ids"></a> [hosted\_zone\_allowed\_ids](#input\_hosted\_zone\_allowed\_ids) | Allows for further scoping down policy for allowed hosted zones. The IDs provided are constructed into ARNs | `list(any)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where your instance of StreamNative Cloud is deployed. Defaults to all regions "*" | `string` | `"*"` | no |
| <a name="input_s3_bucket_pattern"></a> [s3\_bucket\_pattern](#input\_s3\_bucket\_pattern) | Defines the bucket prefix for streamnative managed buckets (backup and offload). Typically defaults to "snc-*", but should match the bucket created using the tiered-storage-resources module | `string` | `"*snc*"` | no |
| <a name="input_s3_kms_key_arns"></a> [s3\_kms\_key\_arns](#input\_s3\_kms\_key\_arns) | List of KMS key ARNs to use for S3 buckets | `list(string)` | `[]` | no |
| <a name="input_sn_policy_version"></a> [sn\_policy\_version](#input\_sn\_policy\_version) | The value of SNVersion tag | `string` | `"3.16.1"` | no |
| <a name="input_source_identities"></a> [source\_identities](#input\_source\_identities) | Place an additional constraint on source identity, disabled by default and only to be used if specified by StreamNative | `list(any)` | `[]` | no |
| <a name="input_source_identity_test"></a> [source\_identity\_test](#input\_source\_identity\_test) | The test to use for source identity | `string` | `"ForAnyValue:StringLike"` | no |
| <a name="input_streamnative_google_account_id"></a> [streamnative\_google\_account\_id](#input\_streamnative\_google\_account\_id) | (Deprecated, use streamnative\_google\_account\_ids instead) The Google Cloud service account ID used by StreamNative for Control Plane operations | `string` | `"108050666045451143798"` | no |
| <a name="input_streamnative_google_account_ids"></a> [streamnative\_google\_account\_ids](#input\_streamnative\_google\_account\_ids) | The Google Cloud service account IDs used by StreamNative for Control Plane operations | `list(string)` | <pre>[<br/>  "108050666045451143798"<br/>]</pre> | no |
| <a name="input_streamnative_principal_ids"></a> [streamnative\_principal\_ids](#input\_streamnative\_principal\_ids) | When set, this applies an additional check for certain StreamNative principals to futher restrict access to which services / users can access an account. | `list(string)` | `[]` | no |
| <a name="input_streamnative_support_access_role_arns"></a> [streamnative\_support\_access\_role\_arns](#input\_streamnative\_support\_access\_role\_arns) | A list ARNs provided by StreamNative that enable streamnative support engineers access the StreamNativeCloudBootstrapRole. This is used only in some initial provisioning and in case of on-call support. | `list(string)` | <pre>[<br/>  "arn:aws:iam::311022431024:role/cloud-support-general"<br/>]</pre> | no |
| <a name="input_streamnative_vendor_access_role_arns"></a> [streamnative\_vendor\_access\_role\_arns](#input\_streamnative\_vendor\_access\_role\_arns) | A list ARNs provided by StreamNative that enable us to work with the Vendor Access Roles created by this module (StreamNativeCloudBootstrapRole, StreamNativeCloudManagementRole). This is how StreamNative is granted access into your AWS account, and should typically be the default value unless directed otherwise. This arns are used *only* for automations. | `list(string)` | <pre>[<br/>  "arn:aws:iam::311022431024:role/cloud-manager"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags to apply to the resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_test_suffix"></a> [test\_suffix](#input\_test\_suffix) | Used in testing to apply us to apply multiple versions of the role | `string` | `""` | no |
| <a name="input_vpc_allowed_ids"></a> [vpc\_allowed\_ids](#input\_vpc\_allowed\_ids) | Allows for further scoping down policy for allowed VPC | `list(any)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_write_policy_files"></a> [write\_policy\_files](#input\_write\_policy\_files) | Write the policy files locally to disk for debugging and validation | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_lbc_policy_arn"></a> [aws\_lbc\_policy\_arn](#output\_aws\_lbc\_policy\_arn) | The ARN of the AWS Load Balancer Controller Policy, if enabled |
| <a name="output_bootstrap_role_arn"></a> [bootstrap\_role\_arn](#output\_bootstrap\_role\_arn) | The ARN of the Bootstrap role, if enabled |
| <a name="output_management_role_arn"></a> [management\_role\_arn](#output\_management\_role\_arn) | The ARN of the Management Role |
| <a name="output_permission_boundary_policy_arn"></a> [permission\_boundary\_policy\_arn](#output\_permission\_boundary\_policy\_arn) | The ARN of the Permssion Boundary Policy |
| <a name="output_runtime_policy_arn"></a> [runtime\_policy\_arn](#output\_runtime\_policy\_arn) | The ARN of the Runtime Policy, if enabled |
<!-- END_TF_DOCS -->
