data "aws_caller_identity" "current" {}
locals {
  account_id                = data.aws_caller_identity.current.account_id
  external_id               = (var.external_id != "" ? [{ test : "StringEquals", variable : "sts:ExternalId", values : [var.external_id] }] : [])
  assume_conditions         = local.external_id
  oidc_providers            = distinct(concat(var.oidc_providers, local.default_oidc_providers))
  tag_set                   = merge({ Vendor = "StreamNative", Module = "StreamNative Volume", SNVersion = var.sn_policy_version }, var.tags)
  # Add streamnative default eks oidc provider
  default_oidc_providers = compact([

  ])
  conditions = [
    for value in local.oidc_providers :
    [
      {
        provider : "${value}",
        test : "StringEquals",
        variable : "${value}:aud",
        values : ["sts.amazonaws.com"]
      },
      {
        provider : "${value}",
        test : "StringEquals",
        variable : "${value}:sub",
        values : [format("system:serviceaccount:%s:*", var.external_id)]
      }
    ]
  ]
}

resource "aws_iam_openid_connect_provider" "streamnative_oidc_providers" {
  count          = length(local.oidc_providers)
  url            = "https://${var.oidc_providers[count.index]}"
  client_id_list = ["sts.amazonaws.com"]
  tags           = local.tag_set
}

data "aws_iam_policy_document" "streamnative_management_access" {
  statement {
    sid     = "AllowStreamNativeControlPlaneAccess"
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

  dynamic "statement" {
    for_each = local.conditions
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [for provider in local.oidc_providers : "arn:aws:iam::${local.account_id}:oidc-provider/${provider}" if "${provider}" == statement.value[0].provider]
      }

      dynamic "condition" {
        for_each = toset(statement.value)
        content {
          test     = condition.value["test"]
          values   = condition.value["values"]
          variable = condition.value["variable"]
        }
      }
    }
  }
}

######
#-- Create the IAM role for the the StreamNative Cloud data access to s3 bucket
######
resource "aws_iam_policy" "access_bucket_role" {
  name        = "sn-${var.external_id}-${var.bucket}-${var.path}"
  description = "This policy sets the limits for the access s3 bucket for StreamNative's vendor access."
  path        = "/StreamNative/"
  policy = templatefile("${path.module}/files/volume_s3_bucket.json.tpl",
    {
      bucket = var.bucket
      path   = var.path
  })
  tags = local.tag_set
}

resource "aws_iam_role" "access_bucket_role" {
  name                 = "sn-${var.external_id}-${var.bucket}-${var.path}"
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