data "aws_caller_identity" "current" {}
locals {
  external_id      = (var.external_id != "" ? [{ test : "StringEquals", variable : "sts:ExternalId", values : [var.external_id] }] : [])
  account_ids      = distinct(concat(var.account_ids, local.default_account_ids))
  identifiers_list = [for account_id in local.account_ids : "arn:aws:iam::${account_id}:root"]
  bucket_list      = distinct([for item in var.buckets : "arn:aws:s3:::${split("/", item)[0]}"])
  bucket_path_list = distinct([for item in var.buckets : "arn:aws:s3:::${item}"])
  tag_set          = merge({ Vendor = "StreamNative", Module = "StreamNative Volume", SNVersion = var.sn_policy_version }, var.tags)
  default_account_ids = compact([
    # will add it in the next pr
  ])
}

data "aws_iam_policy_document" "streamnative_management_access" {
  statement {
    sid     = "AllowStreamNativeControlPlaneAccess"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = distinct(concat(var.streamnative_vendor_access_role_arns, local.identifiers_list))
    }
    dynamic "condition" {
      for_each = local.external_id
      content {
        test     = condition.value["test"]
        values   = condition.value["values"]
        variable = condition.value["variable"]
      }
    }
  }
}

######
#-- Create the IAM role for the the StreamNative Cloud data plane access to s3 bucket
######
resource "aws_iam_role_policy" "access_bucket_role" {
  name = var.role
  role = aws_iam_role.access_bucket_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : local.bucket_list
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource" : [for item in local.bucket_path_list : "${item}/*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutLifecycleConfiguration",
          "s3:GetLifecycleConfiguration"
        ],
        "Resource" : local.bucket_path_list
      }
    ]
  })
}

resource "aws_iam_role" "access_bucket_role" {
  name                 = var.role
  description          = "This role is used by StreamNative for the access s3 bucket."
  assume_role_policy   = data.aws_iam_policy_document.streamnative_management_access.json
  path                 = "/StreamNative/"
  tags                 = local.tag_set
  max_session_duration = 43200
}