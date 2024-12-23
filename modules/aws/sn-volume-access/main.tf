data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  account_id                 = data.aws_caller_identity.current.account_id
  additional_iam_policy_arns = distinct(compact(var.additional_iam_policy_arns))
  allowed_iam_policies       = join(", ", formatlist("\"%s\"", distinct(concat(local.additional_iam_policy_arns, local.default_allowed_iam_policies))))
  aws_partition              = data.aws_partition.current.partition
  assume_conditions          = length(var.external_ids) != 0 ? concat(local.external_ids, local.source_identity, local.principal_check, local.vendor_federation) : concat(local.external_id, local.source_identity, local.principal_check, local.vendor_federation)
  external_id                = (var.external_id != "" ? [{ test : "StringEquals", variable : "sts:ExternalId", values : [var.external_id] }] : [])
  external_ids               = (length(var.external_ids) != 0 ? [{ test : "ForAllValues:StringEquals", variable : "sts:ExternalId", values : var.external_ids }] : [])
  principal_check            = (length(var.streamnative_principal_ids) > 0 ? [{ test : "StringLike", variable : "aws:PrincipalArn", values : var.streamnative_principal_ids }] : [])
  vendor_federation          = (var.enforce_vendor_federation ? [{ test : "StringLike", variable : "aws:FederatedProvider", values : ["accounts.google.com"] }] : [])
  source_identity            = (length(var.source_identities) > 0 ? [{ test : var.source_identity_test, variable : "sts:SourceIdentity", values : var.source_identities }] : [])
  tag_set                    = merge({ Vendor = "StreamNative", Module = "StreamNative Volume", SNVersion = var.sn_policy_version }, var.tags)
  default_allowed_iam_policies = compact([
    "arn:${local.aws_partition}:iam::${local.account_id}:policy/StreamNative/*"
  ])
}

data "aws_iam_policy_document" "streamnative_management_access" {
  statement {
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
      values   = length(var.streamnative_google_account_ids) > 0 ? var.streamnative_google_account_ids : [var.streamnative_google_account_id]
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
  name        = "StreamNativeCloudVolumePermissionBoundary${var.test_suffix}"
  description = "This policy sets the permission boundary for StreamNative's vendor access. It defines the limits of what StreamNative can do within this AWS account."
  path        = "/StreamNative/"
  policy = templatefile("${path.module}/files/sn_volume_permission_boundary_iam_policy.json.tpl",
    {
      account_id           = local.account_id
      allowed_iam_policies = local.allowed_iam_policies
      partition            = local.aws_partition
      region               = var.region
  })
  tags = local.tag_set
}

######
#-- Create the IAM role for the management of the StreamNative Cloud Volume
#-- This role is used by StreamNative for volume management and troubleshooting
#-- of the managed deployment.
######
resource "aws_iam_policy" "management_role" {
  name        = "StreamNativeCloudVolumeManagementPolicy${var.test_suffix}"
  description = "This policy sets the limits for the management role needed for StreamNative's vendor volume access."
  path        = "/StreamNative/"
  policy = templatefile("${path.module}/files/sn_volume_management_role_iam_policy.json.tpl",
    {
      account_id = data.aws_caller_identity.current.account_id
      partition  = local.aws_partition
      region     = var.region
  })
  tags = local.tag_set
}

resource "aws_iam_role" "management_role" {
  name                 = "StreamNativeCloudVolumeManagementRole${var.test_suffix}"
  description          = "This role is used by StreamNative for the day to day management of the StreamNative Cloud Volume deployment."
  assume_role_policy   = data.aws_iam_policy_document.streamnative_management_access.json
  path                 = "/StreamNative/"
  permissions_boundary = aws_iam_policy.permission_boundary.arn
  tags                 = local.tag_set
  max_session_duration = 43200
}

resource "aws_iam_role_policy_attachment" "management_role" {
  policy_arn = aws_iam_policy.management_role.arn
  role       = aws_iam_role.management_role.name
}