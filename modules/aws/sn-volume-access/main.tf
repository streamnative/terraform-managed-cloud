locals {
  external_id                = (var.external_id != "" ? [{ test : "StringEquals", variable : "sts:ExternalId", values : [var.external_id] }] : [])
  assume_conditions          = concat(local.external_id, local.source_identity, local.principal_check, local.vendor_federation)
  support_assume_conditions  = concat(local.external_id, local.source_identity)
  source_identity            = (length(var.source_identities) > 0 ? [{ test : var.source_identity_test, variable : "sts:SourceIdentity", values : var.source_identities }] : [])
  principal_check            = (length(var.streamnative_principal_ids) > 0 ? [{ test : "StringLike", variable : "aws:PrincipalArn", values : var.streamnative_principal_ids }] : [])
  federated_identifiers = distinct(concat(local.default_federated_identifiers, var.additional_federated_identifiers))
  tag_set                    = merge({ Vendor = "StreamNative", Module = "StreamNative Volume", SNVersion = var.sn_policy_version }, var.tags)
  vendor_federation          = (var.enforce_vendor_federation ? [{ test : "StringLike", variable : "aws:FederatedProvider", values : ["accounts.google.com"] }] : [])
  # this is for data plane access aws s3 bucket role
  default_federated_identifiers = compact([
    "accounts.google.com"
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
      identifiers = local.federated_identifiers
    }
    condition {
      test     = "StringEquals"
      values   = length(var.streamnative_google_account_ids) > 0 ? var.streamnative_google_account_ids : [var.streamnative_google_account_id]
      variable = "accounts.google.com:aud"
    }
  }
}

######
#-- Create the IAM role for the the StreamNative Cloud data plane access to s3 bucket
######
resource "aws_iam_policy" "access_bucket_role" {
  name = "sn-${var.external_id}-${var.bucket}-${var.path}"
  description = "This policy sets the limits for the access s3 bucket for StreamNative's vendor access."
  path        = "/StreamNative/"
  policy = templatefile("${path.module}/files/sn_volume_s3_bucket.json.tpl",
  {
    bucket = var.bucket
    path = var.path
  })
  tags = local.tag_set
}

resource "aws_iam_role" "access_bucket_role" {
  name = "sn-${var.external_id}-${var.bucket}-${var.path}"
  description          = "This role is used by StreamNative for the access s3 bucket."
  assume_role_policy   = data.aws_iam_policy_document.streamnative_management_access.json
  path                 = "/StreamNative/"
  tags                 = local.tag_set
  max_session_duration = 43200
}

resource "aws_iam_role_policy_attachment" "access_bucket_role" {
  policy_arn = aws_iam_policy.access_bucket_role.arn
  role       = aws_iam_role.access_bucket_role.name
}