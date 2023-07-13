## Copyright 2023 StreamNative, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_kms_key" "ebs_default" {
  key_id = "alias/aws/ebs"
}

data "aws_kms_key" "s3_default" {
  key_id = "alias/aws/s3"
}

locals {
  account_id                 = data.aws_caller_identity.current.account_id
  additional_iam_policy_arns = distinct(compact(var.additional_iam_policy_arns))
  allowed_iam_policies       = join(", ", formatlist("\"%s\"", distinct(concat(local.additional_iam_policy_arns, local.default_allowed_iam_policies))))
  arn_like_vpcs              = formatlist("\"arn:%s:ec2:%s:%s:vpc/%s\"", local.aws_partition, var.region, local.account_id, var.vpc_allowed_ids)
  arn_like_vpcs_str          = format("[%s]", join(",", local.arn_like_vpcs))
  assume_conditions          = concat(local.external_id, local.source_identity, local.principal_check)
  support_assume_conditions  = concat(local.external_id, local.source_identity)
  aws_partition              = data.aws_partition.current.partition
  build_r53_arns             = [for i, v in var.hosted_zone_allowed_ids : format("\"arn:%s:route53:::hostedzone/%s\"", local.aws_partition, v)]
  ebs_kms_key_arn            = length(var.ebs_kms_key_arns) > 0 ? var.ebs_kms_key_arns : [data.aws_kms_key.ebs_default.arn]
  external_id                = (var.external_id != "" ? [{ test : "StringEquals", variable : "sts:ExternalId", values : [var.external_id] }] : [])
  kms_key_arns               = join(", ", formatlist("\"%s\"", distinct(concat(local.ebs_kms_key_arn, local.s3_kms_key_arn))))
  r53_zone_arns              = format("[%s]", join(",", local.build_r53_arns))
  s3_kms_key_arn             = length(var.s3_kms_key_arns) > 0 ? var.s3_kms_key_arns : [data.aws_kms_key.s3_default.arn]
  source_identity            = (length(var.source_identities) > 0 ? [{ test : var.source_identity_test, variable : "sts:SourceIdentity", values : var.source_identities }] : [])
  principal_check            = (length(var.streamnative_principal_ids) > 0 ? [{ test : "StringLike", variable : "aws:PrincipalArn", values : var.streamnative_principal_ids }] : [])
  tag_set                    = merge({ Vendor = "StreamNative", SNVersion = var.sn_policy_version }, var.tags)

  default_allowed_iam_policies = compact([
    "arn:${local.aws_partition}:iam::${local.account_id}:policy/StreamNative/*",
    "arn:${local.aws_partition}:iam::aws:policy/AmazonEKS*",
    "arn:${local.aws_partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:${local.aws_partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:${local.aws_partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ])
}

######
#-- Trust Relationship for StreamNative Vendor Access Roles
######
data "aws_iam_policy_document" "streamnative_bootstrap_access" {
  dynamic "statement" {
    for_each = length(var.streamnative_vendor_access_role_arns) > 0 ? [1] : []
    content {
      sid      = "AllowStreamNativeVendorAccess"
      effect   = "Allow"
      actions  = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = var.streamnative_vendor_access_role_arns
      }
      dynamic "condition" {
        for_each = local.assume_conditions
        content {
          test     = condition.value["test"]
          values   = condition.value["values"]
          variable = condition.value["variable"]
        }
      }
    }
  }

  statement {
    sid     = "AllowStreamNativeEngineerAccess"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.streamnative_support_access_role_arns
    }
    dynamic "condition" {
      for_each = local.support_assume_conditions
      content {
        test     = condition.value["test"]
        values   = condition.value["values"]
        variable = condition.value["variable"]
      }
    }
  }

  statement {
    sid     = "AllowStreamNativeControlPlaneAccess"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "accounts.google.com"
      ]
    }
    condition {
      test     = "StringEquals"
      values   = [var.streamnative_google_account_id]
      variable = "accounts.google.com:aud"
    }
  }
}

data "aws_iam_policy_document" "streamnative_management_access" {
  dynamic "statement" {
    for_each = length(var.streamnative_vendor_access_role_arns) > 0 ? [1] : []
    content {
      sid     = "AllowStreamNativeVendorAccess"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = var.streamnative_vendor_access_role_arns
      }
      dynamic "condition" {
        for_each = local.assume_conditions
        content {
          test     = condition.value["test"]
          values   = condition.value["values"]
          variable = condition.value["variable"]
        }
      }
    }
  }

  statement {
    sid     = "AllowStreamNativeControlPlaneAccess"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "accounts.google.com"
      ]
    }
    condition {
      test     = "StringEquals"
      values   = [var.streamnative_google_account_id]
      variable = "accounts.google.com:aud"
    }
  }
}

######
#-- Create the IAM Permission Boundary used by all StreamNative
#-- IAM Resources. This restricts what type of access we have
#-- within your AWS Account and is applied to all our IAM Roles
######
resource "aws_iam_policy" "permission_boundary" {
  name        = "StreamNativeCloudPermissionBoundary${var.test_suffix}"
  description = "This policy sets the permission boundary for StreamNative's vendor access. It defines the limits of what StreamNative can do within this AWS account."
  path        = "/StreamNative/"
  policy = templatefile("${path.module}/files/permission_boundary_iam_policy.json.tpl",
    {
      account_id           = local.account_id
      allowed_iam_policies = local.allowed_iam_policies
      cluster_pattern      = var.eks_cluster_pattern
      partition            = local.aws_partition
      region               = var.region
  })
  tags = local.tag_set
}

######
#-- Create the IAM role for bootstraping of the StreamNative Cloud
#-- This role is only needed for the initial StreamNative Cloud
#-- deployment to an AWS account, or when it is being removed.
######
resource "aws_iam_role" "bootstrap_role" {
  count                = var.create_bootstrap_role ? 1 : 0
  name                 = "StreamNativeCloudBootstrapRole${var.test_suffix}"
  description          = "This role is used to bootstrap the StreamNative Cloud within the AWS account. It is limited in scope to the attached policy and also the permission boundary."
  assume_role_policy   = data.aws_iam_policy_document.streamnative_bootstrap_access.json
  path                 = "/StreamNative/"
  permissions_boundary = aws_iam_policy.permission_boundary.arn
  tags                 = local.tag_set
}

resource "aws_iam_policy" "bootstrap_policy" {
  count       = var.create_bootstrap_role ? 1 : 0
  name        = "StreamNativeCloudBootstrapPolicy${var.test_suffix}"
  description = "This policy sets the minimum amount of permissions needed by the StreamNativeCloudBootstrapRole to bootstrap the StreamNative Cloud deployment."
  path        = "/StreamNative/"
  policy = templatefile("${path.module}/files/bootstrap_role_iam_policy.json.tpl",
    {
      account_id      = local.account_id
      region          = var.region
      vpc_ids         = local.arn_like_vpcs_str
      bucket_pattern  = var.s3_bucket_pattern
      cluster_pattern = var.eks_cluster_pattern
      partition       = local.aws_partition
      r53_zone_arns   = local.r53_zone_arns
  })
  tags = local.tag_set
}

resource "aws_iam_role_policy_attachment" "bootstrap_policy" {
  count      = var.create_bootstrap_role ? 1 : 0
  policy_arn = aws_iam_policy.bootstrap_policy[0].arn
  role       = aws_iam_role.bootstrap_role[0].name
}

######
#-- Create the IAM role for the management of the StreamNative Cloud
#-- This role is used by StreamNative for management and troubleshooting
#-- of the managed deployment.
######
resource "aws_iam_policy" "management_role" {
  name        = "StreamNativeCloudManagementPolicy${var.test_suffix}"
  description = "This policy sets the limits for the management role needed for StreamNative's vendor access."
  path        = "/StreamNative/"
  policy = templatefile("${path.module}/files/management_role_iam_policy.json.tpl",
    {
      account_id = data.aws_caller_identity.current.account_id
      partition  = local.aws_partition
      region     = var.region
  })
  tags = local.tag_set
}

resource "aws_iam_role" "management_role" {
  name                 = "StreamNativeCloudManagementRole${var.test_suffix}"
  description          = "This role is used by StreamNative for the day to day management of the StreamNative Cloud deployment."
  assume_role_policy   = data.aws_iam_policy_document.streamnative_management_access.json
  path                 = "/StreamNative/"
  permissions_boundary = aws_iam_policy.permission_boundary.arn
  tags                 = local.tag_set
}

resource "aws_iam_role_policy_attachment" "management_role" {
  policy_arn = aws_iam_policy.management_role.arn
  role       = aws_iam_role.management_role.name
}

######
#-- Creates the IAM Policies used by EKS Cluster add-on services
######
resource "aws_iam_policy" "runtime_policy" {
  name        = "StreamNativeCloudRuntimePolicy${var.test_suffix}"
  description = "This policy defines almost all used by StreamNative cluster components"
  path        = "/StreamNative/"
  policy = templatefile("${path.module}/files/runtime_iam_policy.json.tpl",
    {
      bucket_pattern  = var.s3_bucket_pattern
      cluster_pattern = var.eks_cluster_pattern
      kms_arns        = local.kms_key_arns
      r53_zone_arns   = local.r53_zone_arns
  })
  tags = local.tag_set
}

resource "aws_iam_policy" "alb_policy" {
  name        = "StreamNativeCloudLBPolicy${var.test_suffix}"
  description = "The AWS policy as defined by https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json"
  path        = "/StreamNative/"
  policy = templatefile("${path.module}/files/aws_lb_controller_iam_policy.json.tpl",
    {
      vpc_ids   = local.arn_like_vpcs_str
      partition = local.aws_partition
  })
  tags = local.tag_set
}

######
#-- Write IAM Policies to Local Files
######
resource "local_file" "alb_policy" {
  count = var.write_policy_files ? 1 : 0
  content = templatefile("${path.module}/files/aws_lb_controller_iam_policy.json.tpl",
    {
      vpc_ids   = local.arn_like_vpcs_str
      partition = local.aws_partition
  })
  filename = "alb_policy.json"
}

resource "local_file" "bootstrap_policy" {
  count = var.write_policy_files ? 1 : 0
  content = templatefile("${path.module}/files/bootstrap_role_iam_policy.json.tpl",
    {
      account_id      = local.account_id
      region          = var.region
      vpc_ids         = local.arn_like_vpcs_str
      bucket_pattern  = var.s3_bucket_pattern
      cluster_pattern = var.eks_cluster_pattern
      partition       = local.aws_partition
      r53_zone_arns   = local.r53_zone_arns
  })
  filename = "bootstrap_policy.json"
}

resource "local_file" "management_policy" {
  count = var.write_policy_files ? 1 : 0
  content = templatefile("${path.module}/files/management_role_iam_policy.json.tpl",
    {
      account_id = data.aws_caller_identity.current.account_id
      region     = var.region
      partition  = local.aws_partition
  })
  filename = "management_policy.json"
}

resource "local_file" "runtime_policy" {
  count = var.write_policy_files ? 1 : 0
  content = templatefile("${path.module}/files/runtime_iam_policy.json.tpl",
    {
      bucket_pattern  = var.s3_bucket_pattern
      cluster_pattern = var.eks_cluster_pattern
      kms_arns        = local.kms_key_arns
      r53_zone_arns   = local.r53_zone_arns
  })
  filename = "runtime_policy.json"
}

resource "local_file" "permission_boundary_policy" {
  count = var.write_policy_files ? 1 : 0
  content = templatefile("${path.module}/files/permission_boundary_iam_policy.json.tpl",
    {
      account_id           = local.account_id
      allowed_iam_policies = local.allowed_iam_policies
      cluster_pattern      = var.eks_cluster_pattern
      partition            = local.aws_partition
      region               = var.region
  })
  filename = "permission_boundary_policy.json"
}
