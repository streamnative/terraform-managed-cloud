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

- `external_ids`: A list of [external IDs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html) that correspond to your [Organization IDs](https://docs.streamnative.io/cloud/stable/concepts/concepts#organizations) within StreamNative Cloud. Our services use this ID for any [STS assume role calls](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) to IAM roles created by the module. To find your Organization ID(s), please refer to our [documentation](https://docs.streamnative.io/cloud/stable/use/organization).

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
  source = "github.com/streamnative/terraform-managed-cloud//modules/aws?ref=v3.0.0"
 
  external_id             = "<YOUR_SNCLOUD_ORG_ID>"
  hosted_zone_allowed_ids = [ "<YOUR_R3_HOSTED_ZONE_IDs>" ]
  region                  = "<YOUR_REGION>"

}
```

After [authenticating to your AWS account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) execute the following sequence of commands from the directory containing the `main.tf` configuration file:

1. `terraform init`

<details><summary>(example output)</summary><p>

```bash
$ terraform init

Initializing modules...
- sn_managed_cloud in ../aws

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 4.32.0"...
- Finding latest version of hashicorp/local...
- Installing hashicorp/local v2.2.3...
- Installed hashicorp/local v2.2.3 (signed by HashiCorp)
- Installing hashicorp/aws v4.32.0...
- Installed hashicorp/aws v4.32.0 (signed by HashiCorp)

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

module.aws-managed-cloud.data.aws_caller_identity.current: Reading...
module.aws-managed-cloud.data.aws_partition.current: Reading...
module.aws-managed-cloud.data.aws_kms_key.s3_default: Reading...
module.aws-managed-cloud.data.aws_kms_key.ebs_default: Reading...
module.aws-managed-cloud.data.aws_iam_policy_document.streamnative_vendor_access: Reading...
module.aws-managed-cloud.data.aws_partition.current: Read complete after 0s [id=aws]
module.aws-managed-cloud.data.aws_iam_policy_document.streamnative_control_plane_access: Reading...
module.aws-managed-cloud.data.aws_iam_policy_document.streamnative_vendor_access: Read complete after 0s [id=1415275062]
module.aws-managed-cloud.data.aws_iam_policy_document.streamnative_control_plane_access: Read complete after 0s [id=385961959]
module.aws-managed-cloud.data.aws_kms_key.ebs_default: Read complete after 0s [id=7f6c7a67-5c0a-4be4-8c87-047288a9c37b]
module.aws-managed-cloud.data.aws_kms_key.s3_default: Read complete after 0s [id=a2b08e48-ba16-48b0-ad72-8dfc38198d75]
module.aws-managed-cloud.data.aws_caller_identity.current: Read complete after 0s [id=123456789012]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.aws-managed-cloud.aws_iam_policy.alb_policy will be created
  + resource "aws_iam_policy" "alb_policy" {
      + arn         = (known after apply)
      + description = "The AWS policy as defined by https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json"
      + id          = (known after apply)
      + name        = "StreamNativeCloudLBPolicy"
      + path        = "/StreamNative/"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = [
                          + "iam:CreateServiceLinkedRole",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                    },
                  + {
                      + Action   = [
                          + "ec2:DescribeAccountAttributes",
                          + "ec2:DescribeAddresses",
                          + "ec2:DescribeAvailabilityZones",
                          + "ec2:DescribeInternetGateways",
                          + "ec2:DescribeVpcs",
                          + "ec2:DescribeVpcPeeringConnections",
                          + "ec2:DescribeSubnets",
                          + "ec2:DescribeSecurityGroups",
                          + "ec2:DescribeInstances",
                          + "ec2:DescribeNetworkInterfaces",
                          + "ec2:DescribeTags",
                          + "ec2:GetCoipPoolUsage",
                          + "ec2:DescribeCoipPools",
                          + "elasticloadbalancing:DescribeLoadBalancers",
                          + "elasticloadbalancing:DescribeLoadBalancerAttributes",
                          + "elasticloadbalancing:DescribeListeners",
                          + "elasticloadbalancing:DescribeListenerCertificates",
                          + "elasticloadbalancing:DescribeSSLPolicies",
                          + "elasticloadbalancing:DescribeRules",
                          + "elasticloadbalancing:DescribeTargetGroups",
                          + "elasticloadbalancing:DescribeTargetGroupAttributes",
                          + "elasticloadbalancing:DescribeTargetHealth",
                          + "elasticloadbalancing:DescribeTags",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                  + {
                      + Action   = [
                          + "cognito-idp:DescribeUserPoolClient",
                          + "acm:ListCertificates",
                          + "acm:DescribeCertificate",
                          + "iam:ListServerCertificates",
                          + "iam:GetServerCertificate",
                          + "waf-regional:GetWebACL",
                          + "waf-regional:GetWebACLForResource",
                          + "waf-regional:AssociateWebACL",
                          + "waf-regional:DisassociateWebACL",
                          + "wafv2:GetWebACL",
                          + "wafv2:GetWebACLForResource",
                          + "wafv2:AssociateWebACL",
                          + "wafv2:DisassociateWebACL",
                          + "shield:GetSubscriptionState",
                          + "shield:DescribeProtection",
                          + "shield:CreateProtection",
                          + "shield:DeleteProtection",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                  + {
                      + Action    = [
                          + "ec2:AuthorizeSecurityGroupIngress",
                          + "ec2:RevokeSecurityGroupIngress",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "aws:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                    },
                  + {
                      + Action   = [
                          + "ec2:CreateSecurityGroup",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                  + {
                      + Action    = [
                          + "ec2:CreateTags",
                        ]
                      + Condition = {
                          + Null         = {
                              + "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
                            }
                          + StringEquals = {
                              + "ec2:CreateAction" = "CreateSecurityGroup"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:ec2:*:*:security-group/*"
                    },
                  + {
                      + Action    = [
                          + "ec2:CreateTags",
                          + "ec2:DeleteTags",
                        ]
                      + Condition = {
                          + Null = {
                              + "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true"
                              + "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:ec2:*:*:security-group/*"
                    },
                  + {
                      + Action    = [
                          + "ec2:AuthorizeSecurityGroupIngress",
                          + "ec2:RevokeSecurityGroupIngress",
                          + "ec2:DeleteSecurityGroup",
                        ]
                      + Condition = {
                          + Null         = {
                              + "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
                            }
                          + StringEquals = {
                              + "aws:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                    },
                  + {
                      + Action    = [
                          + "elasticloadbalancing:CreateLoadBalancer",
                          + "elasticloadbalancing:CreateTargetGroup",
                        ]
                      + Condition = {
                          + Null = {
                              + "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                    },
                  + {
                      + Action   = [
                          + "elasticloadbalancing:CreateListener",
                          + "elasticloadbalancing:DeleteListener",
                          + "elasticloadbalancing:CreateRule",
                          + "elasticloadbalancing:DeleteRule",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                  + {
                      + Action    = [
                          + "elasticloadbalancing:AddTags",
                          + "elasticloadbalancing:RemoveTags",
                        ]
                      + Condition = {
                          + Null = {
                              + "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true"
                              + "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                          + "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                          + "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*",
                        ]
                    },
                  + {
                      + Action   = [
                          + "elasticloadbalancing:AddTags",
                          + "elasticloadbalancing:RemoveTags",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                          + "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                          + "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                          + "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*",
                        ]
                    },
                  + {
                      + Action    = [
                          + "elasticloadbalancing:ModifyLoadBalancerAttributes",
                          + "elasticloadbalancing:SetIpAddressType",
                          + "elasticloadbalancing:SetSecurityGroups",
                          + "elasticloadbalancing:SetSubnets",
                          + "elasticloadbalancing:DeleteLoadBalancer",
                          + "elasticloadbalancing:ModifyTargetGroup",
                          + "elasticloadbalancing:ModifyTargetGroupAttributes",
                          + "elasticloadbalancing:DeleteTargetGroup",
                        ]
                      + Condition = {
                          + Null = {
                              + "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                    },
                  + {
                      + Action   = [
                          + "elasticloadbalancing:RegisterTargets",
                          + "elasticloadbalancing:DeregisterTargets",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
                    },
                  + {
                      + Action   = [
                          + "elasticloadbalancing:SetWebAcl",
                          + "elasticloadbalancing:ModifyListener",
                          + "elasticloadbalancing:AddListenerCertificates",
                          + "elasticloadbalancing:RemoveListenerCertificates",
                          + "elasticloadbalancing:ModifyRule",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id   = (known after apply)
      + tags        = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
      + tags_all    = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
    }

  # module.aws-managed-cloud.aws_iam_policy.bootstrap_policy[0] will be created
  + resource "aws_iam_policy" "bootstrap_policy" {
      + arn         = (known after apply)
      + description = "This policy sets the minimum amount of permissions needed by the StreamNativeCloudBootstrapRole to bootstrap the StreamNative Cloud deployment."
      + id          = (known after apply)
      + name        = "StreamNativeCloudBootstrapPolicy"
      + path        = "/StreamNative/"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "kms:CreateAlias",
                          + "kms:DeleteAlias",
                          + "kms:ScheduleKeyDeletion",
                          + "logs:CreateLogGroup",
                          + "logs:PutRetentionPolicy",
                          + "route53:CreateHostedZone",
                          + "route53:ChangeTagsForResource",
                          + "support:*",
                          + "servicequotas:List*",
                          + "servicequotas:Get*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                      + Sid      = "UnResRW"
                    },
                  + {
                      + Action   = [
                          + "acm:ImportCertificate",
                          + "acm:ListCertificates",
                          + "acm:ListTagsForCertificate",
                          + "autoscaling:Describe*",
                          + "ec2:Describe*",
                          + "ec2:Get*",
                          + "eks:Describe*",
                          + "eks:List*",
                          + "elasticloadbalancing:Describe*",
                          + "iam:GetInstanceProfile",
                          + "iam:GetOpenIDConnectProvider",
                          + "iam:GetPolicy",
                          + "iam:GetPolicyVersion",
                          + "iam:GetRole",
                          + "iam:List*",
                          + "kms:DescribeKey",
                          + "kms:GetKeyPolicy",
                          + "kms:GetKeyRotationStatus",
                          + "kms:ListAliases",
                          + "kms:ListResourceTags",
                          + "logs:Describe*",
                          + "logs:List*",
                          + "route53:Get*",
                          + "route53:List*",
                          + "s3:ListAllMyBuckets",
                          + "s3:ListBucket",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                      + Sid      = "RO"
                    },
                  + {
                      + Action   = "iam:AttachRolePolicy"
                      + Effect   = "Allow"
                      + Resource = "arn:aws:iam::123456789012:role/StreamNative/*"
                      + Sid      = "ResRlPol"
                    },
                  + {
                      + Action    = [
                          + "ec2:AuthorizeSecurityGroup*",
                          + "ec2:RevokeSecurityGroup*",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "aws:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                      + Sid       = "SecGrpVPC"
                    },
                  + {
                      + Action    = [
                          + "ec2:RunInstances",
                        ]
                      + Condition = {
                          + ArnLikeIfExists = {
                              + "ec2:Vpc" = [
                                  + "arn:aws:ec2:*:123456789012:vpc/*",
                                ]
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                      + Sid       = "RunInst"
                    },
                  + {
                      + Action   = [
                          + "route53:ChangeResourceRecordSets",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:route53:::hostedzone/*",
                        ]
                      + Sid      = "ResR53Z"
                    },
                  + {
                      + Action   = [
                          + "eks:DeleteNodeGroup",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:eks:*:123456789012:nodegroup/*/*snc*/*",
                        ]
                      + Sid      = "ResEKS"
                    },
                  + {
                      + Action    = [
                          + "autoscaling:*Tags",
                          + "autoscaling:Delete*",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "autoscaling:ResourceTag/cluster-name" = "*snc*"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "*",
                        ]
                      + Sid       = "AsgTags"
                    },
                  + {
                      + Action    = [
                          + "ec2:Associate*",
                          + "ec2:Delete*",
                          + "ec2:Disassociate*",
                          + "ec2:Modify*",
                          + "ec2:*TransitGateway*",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "ec2:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "*",
                        ]
                      + Sid       = "EC2Tags"
                    },
                  + {
                      + Action    = [
                          + "elasticloadbalancing:De*",
                          + "elasticloadbalancing:*LoadBalancer*",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "elasticloadbalancing:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "*",
                        ]
                      + Sid       = "ELBTags"
                    },
                  + {
                      + Action    = [
                          + "eks:TagResource",
                          + "eks:UntagResource",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "aws:ResourceTag/cluster-name" = "*snc*"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                      + Sid       = "AllowTag"
                    },
                  + {
                      + Action    = [
                          + "acm:AddTagsToCertificate",
                          + "acm:ImportCertificate",
                          + "acm:RemoveTagsFromCertificate",
                          + "acm:RequestCertificate",
                          + "autoscaling:Create*",
                          + "ec2:*TransitGateway*",
                          + "ec2:AllocateAddress",
                          + "ec2:Create*",
                          + "eks:Create*",
                          + "eks:RegisterCluster",
                          + "eks:TagResource",
                          + "elasticloadbalancing:Add*",
                          + "kms:CreateKey",
                          + "kms:TagResource",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "aws:RequestTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                      + Sid       = "ReqReqTag"
                    },
                  + {
                      + Action    = [
                          + "acm:DeleteCertificate",
                          + "acm:DescribeCertificate",
                          + "acm:ExportCertificate",
                          + "acm:GetCertificate",
                          + "acm:ImportCertificate",
                          + "acm:RemoveTagsFromCertificate",
                          + "acm:ResendValidationEmail",
                          + "autoscaling:AttachInstances",
                          + "autoscaling:CreateOrUpdateTags",
                          + "autoscaling:Detach*",
                          + "autoscaling:Update*",
                          + "autoscaling:Resume*",
                          + "autoscaling:Suspend*",
                          + "autoscaling:SetDesired*",
                          + "ec2:AssignPrivateIpAddresses",
                          + "ec2:AttachInternetGateway",
                          + "ec2:CreateLaunchTemplateVersion",
                          + "ec2:CreateNatGateway",
                          + "ec2:CreateNetworkInterface",
                          + "ec2:CreateRoute",
                          + "ec2:CreateRouteTable",
                          + "ec2:CreateSecurityGroup",
                          + "ec2:CreateSubnet",
                          + "ec2:CreateTags",
                          + "ec2:CreateVpcEndpoint",
                          + "ec2:Detach*",
                          + "ec2:Release*",
                          + "ec2:Revoke*",
                          + "ec2:TerminateInstances",
                          + "ec2:Update*",
                          + "eks:DeleteAddon",
                          + "eks:DeleteCluster",
                          + "eks:DeleteFargateProfile",
                          + "eks:DeregisterCluster",
                          + "eks:U*",
                          + "elasticloadbalancing:*Listener",
                          + "elasticloadbalancing:*Rule",
                          + "elasticloadbalancing:*TargetGroup",
                          + "elasticloadbalancing:Set*",
                          + "elasticloadbalancing:Re*",
                          + "logs:DeleteLogGroup",
                          + "logs:PutRetentionPolicy",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "aws:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                      + Sid       = "ReqResrcTag"
                    },
                  + {
                      + Action   = [
                          + "s3:CreateBucket",
                          + "s3:Delete*",
                          + "s3:Get*",
                          + "s3:List*",
                          + "s3:PutBucket*",
                          + "s3:PutObject*",
                          + "s3:PutLifecycle*",
                          + "s3:PutAccelerateConfiguration",
                          + "s3:PutAccessPointPolicy",
                          + "s3:PutAccountPublicAccessBlock",
                          + "s3:PutAnalyticsConfiguration",
                          + "s3:PutEncryptionConfiguration",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:s3:::*snc*",
                        ]
                      + Sid      = "ResS3"
                    },
                  + {
                      + Action    = [
                          + "iam:AddRoleToInstanceProfile",
                          + "iam:DeleteInstanceProfile",
                          + "iam:DeleteOpenIDConnectProvider",
                          + "iam:DeleteRole",
                          + "iam:DeleteServiceLinkedRole",
                          + "iam:DetachRolePolicy",
                          + "iam:PutRolePermissionsBoundary",
                          + "iam:RemoveRoleFromInstanceProfile",
                          + "iam:SetDefaultPolicyVersion",
                          + "iam:UpdateAssumeRolePolicy",
                          + "iam:UpdateOpenIDConnectProviderThumbprint",
                          + "iam:UpdateRole",
                          + "iam:UpdateRoleDescription",
                          + "iam:Untag*",
                          + "iam:CreateOpenIDConnectProvider",
                          + "iam:TagPolicy",
                          + "iam:TagRole",
                          + "iam:TagInstanceProfile",
                          + "iam:TagOpenIDConnectProvider",
                          + "iam:DeletePolicy",
                          + "iam:DeletePolicyVersion",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "aws:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "arn:aws:iam::123456789012:role/StreamNative/*",
                          + "arn:aws:iam::123456789012:policy/StreamNative/*",
                          + "arn:aws:iam::123456789012:oidc-provider/*",
                        ]
                      + Sid       = "IAMReqTag"
                    },
                  + {
                      + Action   = "iam:CreateServiceLinkedRole"
                      + Effect   = "Allow"
                      + Resource = "arn:aws:iam::123456789012:role/aws-service-role/*"
                      + Sid      = "SvcLnkRl"
                    },
                  + {
                      + Action    = [
                          + "iam:PassRole",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "iam:PassedToService" = "eks.amazonaws.com"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "arn:aws:iam::123456789012:role/*snc*",
                        ]
                      + Sid       = "ResPsRlEKS"
                    },
                  + {
                      + Action    = [
                          + "iam:CreateRole",
                        ]
                      + Condition = {
                          + StringEqualsIgnoreCase = {
                              + "iam:PermissionsBoundary" = "arn:aws:iam:::policy/StreamNative/StreamNativeCloudPermissionBoundary"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:iam::123456789012:role/StreamNative/*"
                      + Sid       = "RqPBRls"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id   = (known after apply)
      + tags        = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
      + tags_all    = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
    }

  # module.aws-managed-cloud.aws_iam_policy.management_role will be created
  + resource "aws_iam_policy" "management_role" {
      + arn         = (known after apply)
      + description = "This policy sets the limits for the management role needed for StreamNative's vendor access."
      + id          = (known after apply)
      + name        = "StreamNativeCloudManagementPolicy"
      + path        = "/StreamNative/"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "acm:List*",
                          + "acm:ImportCertificate",
                          + "cloudwatch:Describe*",
                          + "cloudwatch:List*",
                          + "cloudwatch:Get*",
                          + "logs:Describe*",
                          + "logs:List*",
                          + "logs:Filter*",
                          + "logs:StartQuery",
                          + "logs:StopQuery",
                          + "route53:Get*",
                          + "route53:List*",
                          + "support:*",
                          + "servicequotas:List*",
                          + "servicequotas:Get*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                      + Sid      = "AllowedServices"
                    },
                  + {
                      + Action    = [
                          + "autoscaling:Describe*",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "autoscaling:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "*",
                        ]
                      + Sid       = "AsgTags"
                    },
                  + {
                      + Action    = [
                          + "ec2:Describe*",
                          + "ec2:Get*",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "ec2:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "*",
                        ]
                      + Sid       = "EC2Tags"
                    },
                  + {
                      + Action    = [
                          + "elasticloadbalancing:Describe*",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "elasticloadbalancing:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "*",
                        ]
                      + Sid       = "ELBTags"
                    },
                  + {
                      + Action    = [
                          + "eks:Describe*",
                          + "eks:List*",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "eks:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "*",
                        ]
                      + Sid       = "EKSTags"
                    },
                  + {
                      + Action   = [
                          + "iam:GetPolicy*",
                          + "iam:GetRole*",
                          + "iam:ListRole*",
                          + "iam:ListPolic*",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:iam::123456789012:role/StreamNative/*",
                          + "arn:aws:iam::123456789012:policy/StreamNative/*",
                          + "arn:aws:iam::aws:policy/*",
                        ]
                      + Sid      = "AllowedIAMReadActions"
                    },
                  + {
                      + Action    = [
                          + "iam:CreateRole",
                          + "iam:TagRole",
                        ]
                      + Condition = {
                          + StringEqualsIgnoreCase = {
                              + "aws:RequestTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "arn:aws:iam::123456789012:role/StreamNative/*",
                        ]
                      + Sid       = "IamRequireRequestTag"
                    },
                  + {
                      + Action    = [
                          + "iam:AttachRolePolicy",
                        ]
                      + Condition = {
                          + ArnEquals = {
                              + "iam:PolicyARN" = [
                                  + "arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudManagementPolicy",
                                ]
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:iam::123456789012:role/StreamNative/*"
                      + Sid       = "IamAttach"
                    },
                  + {
                      + Action    = [
                          + "iam:DeleteRole",
                          + "iam:DetachRolePolicy",
                          + "iam:PutRolePermissionsBoundary",
                          + "iam:SetDefaultPolicyVersion",
                          + "iam:UpdateAssumeRolePolicy",
                          + "iam:UpdateRole",
                          + "iam:UpdateRoleDescription",
                        ]
                      + Condition = {
                          + StringEqualsIgnoreCase = {
                              + "aws:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "arn:aws:iam::123456789012:role/StreamNative/*",
                          + "arn:aws:iam::123456789012:policy/StreamNative/*",
                        ]
                      + Sid       = "IamRequireResourceTag"
                    },
                  + {
                      + Action    = [
                          + "acm:DeleteCertificate",
                          + "acm:DescribeCertificate",
                          + "acm:GetCertificate",
                          + "autoscaling:CancelInstanceRefresh",
                          + "autoscaling:PutScalingPolicy",
                          + "autoscaling:ResumeProcesses",
                          + "autoscaling:SetDesiredCapacity",
                          + "autoscaling:StartInstanceRefresh",
                          + "autoscaling:SuspendProcesses",
                          + "autoscaling:UpdateAutoScalingGroup",
                          + "eks:UpdateNodegroupConfig",
                          + "eks:UpdateNodegroupVersion",
                        ]
                      + Condition = {
                          + StringEqualsIgnoreCase = {
                              + "aws:ResourceTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "*",
                        ]
                      + Sid       = "RequireResourceTag"
                    },
                  + {
                      + Action    = [
                          + "acm:AddTagsToCertificate",
                          + "acm:ImportCertificate",
                        ]
                      + Condition = {
                          + StringEqualsIgnoreCase = {
                              + "aws:RequestTag/Vendor" = "StreamNative"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "*",
                        ]
                      + Sid       = "RequireRequestTag"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id   = (known after apply)
      + tags        = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
      + tags_all    = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
    }

  # module.aws-managed-cloud.aws_iam_policy.permission_boundary will be created
  + resource "aws_iam_policy" "permission_boundary" {
      + arn         = (known after apply)
      + description = "This policy sets the permission boundary for StreamNative's vendor access. It defines the limits of what StreamNative can do within this AWS account."
      + id          = (known after apply)
      + name        = "StreamNativeCloudPermissionBoundary"
      + path        = "/StreamNative/"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "acm:*",
                          + "autoscaling:*",
                          + "cognito-idp:*",
                          + "dynamodb:*",
                          + "ec2:*",
                          + "ecr:*",
                          + "eks:*",
                          + "elasticloadbalancing:*",
                          + "iam:GetInstanceProfile",
                          + "iam:GetOpenIDConnectProvider",
                          + "iam:GetPolicy",
                          + "iam:GetPolicyVersion",
                          + "iam:GetRole",
                          + "iam:GetServerCertificate",
                          + "iam:ListAttachedRolePolicies",
                          + "iam:ListEntitiesForPolicy",
                          + "iam:ListInstanceProfile*",
                          + "iam:ListOpenIDConnectProvider*",
                          + "iam:ListPolicies",
                          + "iam:ListPolicyTags",
                          + "iam:ListPolicyVersions",
                          + "iam:ListRole*",
                          + "iam:ListServerCertificates",
                          + "kms:*",
                          + "logs:*",
                          + "route53:*",
                          + "s3:*",
                          + "servicequotas:*",
                          + "shield:*",
                          + "support:*",
                          + "sts:*",
                          + "waf-regional:*",
                          + "wafv2:*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                      + Sid      = "AllowedServices"
                    },
                  + {
                      + Action   = [
                          + "iam:AddRoleToInstanceProfile",
                          + "iam:CreateOpenIDConnectProvider",
                          + "iam:CreateRole",
                          + "iam:CreateServiceLinkedRole",
                          + "iam:DeleteInstanceProfile",
                          + "iam:DeleteOpenIDConnectProvider",
                          + "iam:DeletePolicy",
                          + "iam:DeletePolicyVersion",
                          + "iam:DeleteRole",
                          + "iam:DeleteServiceLinkedRole",
                          + "iam:DetachRolePolicy",
                          + "iam:PassRole",
                          + "iam:PutRolePermissionsBoundary",
                          + "iam:RemoveRoleFromInstanceProfile",
                          + "iam:SetDefaultPolicyVersion",
                          + "iam:TagInstanceProfile",
                          + "iam:TagOpenIDConnectProvider",
                          + "iam:TagPolicy",
                          + "iam:TagRole",
                          + "iam:Untag*",
                          + "iam:UpdateAssumeRolePolicy",
                          + "iam:UpdateOpenIDConnectProviderThumbprint",
                          + "iam:UpdateRole",
                          + "iam:UpdateRoleDescription",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:iam::aws:policy/*",
                          + "arn:aws:iam::123456789012:role/aws-service-role/*",
                          + "arn:aws:iam::123456789012:role/*snc*",
                          + "arn:aws:iam::123456789012:role/StreamNative/*",
                          + "arn:aws:iam::123456789012:policy/StreamNative/*",
                          + "arn:aws:iam::123456789012:oidc-provider/*",
                          + "arn:aws:iam::123456789012:instance-profile/*",
                          + "arn:aws:iam::123456789012:server-certificate/*",
                        ]
                      + Sid      = "IamRestrictions"
                    },
                  + {
                      + Action    = [
                          + "iam:PassRole",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "iam:PassedToService" = "eks.amazonaws.com"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:iam::123456789012:role/*snc*"
                      + Sid       = "RestrictPassRoleToEKS"
                    },
                  + {
                      + Action    = [
                          + "iam:AttachRolePolicy",
                        ]
                      + Condition = {
                          + "ForAnyValue:ArnLike" = {
                              + "iam:PolicyARN" = [
                                  + "arn:aws:iam::123456789012:policy/StreamNative/*",
                                  + "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
                                  + "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
                                  + "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
                                  + "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
                                  + "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
                                  + "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
                                  + "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
                                ]
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:iam::123456789012:role/StreamNative/*"
                      + Sid       = "AllowedIAMManagedPolicies"
                    },
                  + {
                      + Action    = [
                          + "iam:CreateRole",
                        ]
                      + Condition = {
                          + StringEqualsIgnoreCase = {
                              + "aws:ResourceTag/Vendor"  = "StreamNative"
                              + "iam:PermissionsBoundary" = "arn:aws:iam:::policy/StreamNative/StreamNativeCloudPermissionBoundary"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:iam::123456789012:role/StreamNative/*"
                      + Sid       = "RequirePermissionBoundaryForIamRoles"
                    },
                  + {
                      + Action   = [
                          + "iam:Create*",
                          + "iam:Delete*",
                          + "iam:Put*",
                          + "iam:Tag*",
                          + "iam:Untag*",
                          + "iam:Update*",
                          + "iam:Set*",
                        ]
                      + Effect   = "Deny"
                      + Resource = [
                          + "arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudBootstrapPolicy",
                          + "arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudLBPolicy",
                          + "arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudManagementPolicy",
                          + "arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudPermissionBoundary",
                          + "arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudRuntimePolicy",
                          + "arn:aws:iam::123456789012:role/StreamNative/StreamNativeCloudBootstrapRole",
                          + "arn:aws:iam::123456789012:role/StreamNative/StreamNativeCloudManagementRole",
                        ]
                      + Sid      = "RestrictChangesToVendorAccess"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id   = (known after apply)
      + tags        = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
      + tags_all    = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
    }

  # module.aws-managed-cloud.aws_iam_policy.runtime_policy will be created
  + resource "aws_iam_policy" "runtime_policy" {
      + arn         = (known after apply)
      + description = "This policy defines almost all used by StreamNative cluster components"
      + id          = (known after apply)
      + name        = "StreamNativeCloudRuntimePolicy"
      + path        = "/StreamNative/"
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "secretsmanager:ListSecrets",
                          + "route53:ListTagsForResource",
                          + "route53:ListResourceRecordSets",
                          + "route53:ListHostedZones*",
                          + "route53:GetChange",
                          + "ec2:DescribeVolumesModifications",
                          + "ec2:DescribeVolumes",
                          + "ec2:DescribeTags",
                          + "ec2:DescribeSnapshots",
                          + "autoscaling:Describe*",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "*",
                        ]
                      + Sid      = "ro"
                    },
                  + {
                      + Action   = "route53:ChangeResourceRecordSets"
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:route53:::hostedzone/*",
                        ]
                      + Sid      = "r53sc"
                    },
                  + {
                      + Action    = [
                          + "autoscaling:UpdateAutoScalingGroup",
                          + "autoscaling:TerminateInstanceInAutoScalingGroup",
                          + "autoscaling:SetDesiredCapacity",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "autoscaling:ResourceTag/eks:cluster-name" = "*snc*"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                      + Sid       = "asg"
                    },
                  + {
                      + Action    = [
                          + "kms:RevokeGrant",
                          + "kms:ListGrants",
                          + "kms:CreateGrant",
                        ]
                      + Condition = {
                          + Bool = {
                              + "kms:GrantIsForAWSResource" = [
                                  + "true",
                                ]
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "arn:aws:kms:us-west-2:123456789012:key/7f6c7a67-5c0a-4be4-8c87-047288a9c37b",
                          + "arn:aws:kms:us-west-2:123456789012:key/a2b08e48-ba16-48b0-ad72-8dfc38198d75",
                        ]
                      + Sid       = "csik1"
                    },
                  + {
                      + Action   = [
                          + "kms:ReEncrypt*",
                          + "kms:GenerateDataKey*",
                          + "kms:Encrypt",
                          + "kms:DescribeKey",
                          + "kms:Decrypt",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:kms:us-west-2:123456789012:key/7f6c7a67-5c0a-4be4-8c87-047288a9c37b",
                          + "arn:aws:kms:us-west-2:123456789012:key/a2b08e48-ba16-48b0-ad72-8dfc38198d75",
                        ]
                      + Sid      = "csik2"
                    },
                  + {
                      + Action   = [
                          + "s3:ListMultipart*",
                          + "s3:ListBucket",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::*snc*"
                      + Sid      = "s3b"
                    },
                  + {
                      + Action   = [
                          + "s3:Put*",
                          + "s3:List*",
                          + "s3:*Object",
                          + "s3:*Multipart*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::*snc*"
                      + Sid      = "s3o"
                    },
                  + {
                      + Action    = [
                          + "ec2:CreateVolume",
                          + "ec2:CreateSnapshot",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "aws:RequestTag/kubernetes.io/cluster/*snc*" = [
                                  + "owned",
                                ]
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                      + Sid       = "vbc"
                    },
                  + {
                      + Action    = "ec2:CreateTags"
                      + Condition = {
                          + StringEquals = {
                              + "ec2:CreateAction" = [
                                  + "CreateVolume",
                                  + "CreateSnapshot",
                                ]
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = [
                          + "arn:aws:ec2:*:*:volume/*",
                          + "arn:aws:ec2:*:*:snapshot/*",
                        ]
                      + Sid       = "vbt"
                    },
                  + {
                      + Action    = "ec2:DeleteSnapshot"
                      + Condition = {
                          + StringLike = {
                              + "aws:ResourceTag/kubernetes.io/cluster/*snc*" = [
                                  + "owned",
                                ]
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "*"
                      + Sid       = "vbd"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id   = (known after apply)
      + tags        = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
      + tags_all    = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
    }

  # module.aws-managed-cloud.aws_iam_role.bootstrap_role[0] will be created
  + resource "aws_iam_role" "bootstrap_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::311022431024:role/cloud-manager"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + description           = "This role is used to bootstrap the StreamNative Cloud within the AWS account. It is limited in scope to the attached policy and also the permission boundary."
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "StreamNativeCloudBootstrapRole"
      + name_prefix           = (known after apply)
      + path                  = "/StreamNative/"
      + permissions_boundary  = (known after apply)
      + tags                  = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
      + tags_all              = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = (known after apply)
          + policy = (known after apply)
        }
    }

  # module.aws-managed-cloud.aws_iam_role.management_role will be created
  + resource "aws_iam_role" "management_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Condition = {
                          + StringEquals = {
                              + "sts:ExternalId" = "*"
                            }
                        }
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::311022431024:role/cloud-manager"
                        }
                      + Sid       = "AllowStreamNativeVendorAccess"
                    },
                  + {
                      + Action    = "sts:AssumeRoleWithWebIdentity"
                      + Condition = {
                          + StringEquals = {
                              + "accounts.google.com:aud" = "108050666045451143798"
                            }
                        }
                      + Effect    = "Allow"
                      + Principal = {
                          + Federated = "accounts.google.com"
                        }
                      + Sid       = "AllowStreamNativeControlPlaneAccess"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + description           = "This role is used by StreamNative for the day to day management of the StreamNative Cloud deployment."
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "StreamNativeCloudManagementRole"
      + name_prefix           = (known after apply)
      + path                  = "/StreamNative/"
      + permissions_boundary  = (known after apply)
      + tags                  = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
      + tags_all              = {
          + "SNVersion" = "3.0.0"
          + "Vendor"    = "StreamNative"
        }
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = (known after apply)
          + policy = (known after apply)
        }
    }

  # module.aws-managed-cloud.aws_iam_role_policy_attachment.bootstrap_policy[0] will be created
  + resource "aws_iam_role_policy_attachment" "bootstrap_policy" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "StreamNativeCloudBootstrapRole"
    }

  # module.aws-managed-cloud.aws_iam_role_policy_attachment.management_role will be created
  + resource "aws_iam_role_policy_attachment" "management_role" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "StreamNativeCloudManagementRole"
    }

Plan: 9 to add, 0 to change, 0 to destroy.
```
</p></details>

3. `terraform apply`

<details><summary>(example output)</summary><p>

```bash
$ terraform apply

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.aws-managed-cloud.aws_iam_policy.management_role: Creating...
module.aws-managed-cloud.aws_iam_policy.permission_boundary: Creating...
module.aws-managed-cloud.aws_iam_policy.runtime_policy: Creating...
module.aws-managed-cloud.aws_iam_policy.bootstrap_policy[0]: Creating...
module.aws-managed-cloud.aws_iam_policy.alb_policy: Creating...
module.aws-managed-cloud.aws_iam_policy.permission_boundary: Creation complete after 1s [id=arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudPermissionBoundary]
module.aws-managed-cloud.aws_iam_policy.management_role: Creation complete after 1s [id=arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudManagementPolicy]
module.aws-managed-cloud.aws_iam_policy.runtime_policy: Creation complete after 1s [id=arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudRuntimePolicy]
module.aws-managed-cloud.aws_iam_role.bootstrap_role[0]: Creating...
module.aws-managed-cloud.aws_iam_role.management_role: Creating...
module.aws-managed-cloud.aws_iam_policy.bootstrap_policy[0]: Creation complete after 1s [id=arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudBootstrapPolicy]
module.aws-managed-cloud.aws_iam_policy.alb_policy: Creation complete after 1s [id=arn:aws:iam::123456789012:policy/StreamNative/StreamNativeCloudLBPolicy]
module.aws-managed-cloud.aws_iam_role.bootstrap_role[0]: Creation complete after 1s [id=StreamNativeCloudBootstrapRole]
module.aws-managed-cloud.aws_iam_role.management_role: Creation complete after 1s [id=StreamNativeCloudManagementRole]
module.aws-managed-cloud.aws_iam_role_policy_attachment.bootstrap_policy[0]: Creating...
module.aws-managed-cloud.aws_iam_role_policy_attachment.management_role: Creating...
module.aws-managed-cloud.aws_iam_role_policy_attachment.management_role: Creation complete after 0s [id=StreamNativeCloudManagementRole-20220928205225222500000001]
module.aws-managed-cloud.aws_iam_role_policy_attachment.bootstrap_policy[0]: Creation complete after 0s [id=StreamNativeCloudBootstrapRole-20220928205225225100000002]

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.
```
</p></details>


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.32.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.32.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.alb_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bootstrap_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.management_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.permission_boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.runtime_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.bootstrap_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.management_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bootstrap_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.management_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [local_file.alb_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.bootstrap_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.management_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.permission_boundary_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.runtime_policy](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.streamnative_control_plane_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.streamnative_vendor_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.ebs_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_kms_key.s3_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_iam_policy_arns"></a> [additional\_iam\_policy\_arns](#input\_additional\_iam\_policy\_arns) | Provide a list of additional IAM policy ARNs allowed for use with iam:AttachRolePolicy, defined in the StreamNativePermissionBoundary. | `list(string)` | `[]` | no |
| <a name="input_create_bootstrap_role"></a> [create\_bootstrap\_role](#input\_create\_bootstrap\_role) | Whether or not to create the bootstrap role, which is used by StreamNative for the initial deployment of StreamNative Cloud | `string` | `true` | no |
| <a name="input_ebs_kms_key_arns"></a> [ebs\_kms\_key\_arns](#input\_ebs\_kms\_key\_arns) | Sets the list of allowed KMS key ARNs, if not set, uses the default EBS KMS key | `list(any)` | `[]` | no |
| <a name="input_eks_cluster_pattern"></a> [eks\_cluster\_pattern](#input\_eks\_cluster\_pattern) | Defines the EKS cluster prefix for streamnative clusters. This should normally remain the default value. | `string` | `"*snc*"` | no |
| <a name="input_eks_nodepool_pattern"></a> [eks\_nodepool\_pattern](#input\_eks\_nodepool\_pattern) | Defines the prefix that scopes which node pools StreamNative is allowed to use. This should normally remain the default value. | `string` | `"*snc*"` | no |
| <a name="input_external_ids"></a> [external\_ids](#input\_external\_ids) | A list of external IDs that correspond to your Organizations within StreamNative Cloud. Used for all STS assume role calls to the IAM roles created by the module. This will be the organization ID in the StreamNative console, e.g. "["o-xhopj"]". | `list(string)` | n/a | yes |
| <a name="input_hosted_zone_allowed_ids"></a> [hosted\_zone\_allowed\_ids](#input\_hosted\_zone\_allowed\_ids) | Allows for further scoping down policy for allowed hosted zones. The IDs provided are constructed into ARNs | `list(any)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where your instance of StreamNative Cloud is deployed. Defaults to all regions "*" | `string` | `"*"` | no |
| <a name="input_s3_bucket_pattern"></a> [s3\_bucket\_pattern](#input\_s3\_bucket\_pattern) | Defines the bucket prefix for StreamNative managed buckets (backup and offload). Typically defaults to "snc-*", but should match the bucket created using the tiered storage resources module | `string` | `"*snc*"` | no |
| <a name="input_s3_kms_key_arns"></a> [s3\_kms\_key\_arns](#input\_s3\_kms\_key\_arns) | List of KMS key ARNs to use for S3 buckets | `list(string)` | `[]` | no |
| <a name="input_sn_policy_version"></a> [sn\_policy\_version](#input\_sn\_policy\_version) | The value of SNVersion tag | `string` | `"3.0.0"` | no |
| <a name="input_source_identities"></a> [source\_identities](#input\_source\_identities) | Place an additional constraint on source identity, disabled by default and only to be used if specified by StreamNative | `list(any)` | `[]` | no |
| <a name="input_source_identity_test"></a> [source\_identity\_test](#input\_source\_identity\_test) | The test to use for source identity | `string` | `"ForAnyValue:StringLike"` | no |
| <a name="input_streamnative_google_account_id"></a> [streamnative\_google\_account\_id](#input\_streamnative\_google\_account\_id) | The Google Cloud service account ID used by StreamNative for Control Plane operations | `string` | `"108050666045451143798"` | no |
| <a name="input_streamnative_vendor_access_role_arns"></a> [streamnative\_vendor\_access\_role\_arns](#input\_streamnative\_vendor\_access\_role\_arns) | A list of  ARNs provided by StreamNative that enable us to work with the Vendor Access Roles created by this module (StreamNativeCloudBootstrapRole, StreamNativeCloudManagementRole). This is how StreamNative is granted access into your AWS account and should typically be the default value unless directed otherwise. | `list(string)` | <pre>[<br>  "arn:aws:iam::311022431024:role/cloud-manager"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags to apply to the resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_vpc_allowed_ids"></a> [vpc\_allowed\_ids](#input\_vpc\_allowed\_ids) | Allows for further scoping down policy for allowed VPC | `list(any)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_write_policy_files"></a> [write\_policy\_files](#input\_write\_policy\_files) | Write the policy files locally to disk for debugging and validation | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_lbc_policy_arn"></a> [aws\_lbc\_policy\_arn](#output\_aws\_lbc\_policy\_arn) | The ARN of the AWS Load Balancer Controller Policy, if enabled |
| <a name="output_bootstrap_role_arn"></a> [bootstrap\_role\_arn](#output\_bootstrap\_role\_arn) | The ARN of the Bootstrap role, if enabled |
| <a name="output_management_role_arn"></a> [management\_role\_arn](#output\_management\_role\_arn) | The ARN of the Management Role |
| <a name="output_permission_boundary_policy_arn"></a> [permission\_boundary\_policy\_arn](#output\_permission\_boundary\_policy\_arn) | The ARN of the Permission Boundary Policy |
| <a name="output_runtime_policy_arn"></a> [runtime\_policy\_arn](#output\_runtime\_policy\_arn) | The ARN of the Runtime Policy, if enabled |
<!-- END_TF_DOCS -->
