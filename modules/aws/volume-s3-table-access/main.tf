data "aws_caller_identity" "current" {}
locals {
  external_id        = (var.external_id != "" ? [{ test : "StringEquals", variable : "sts:ExternalId", values : [var.external_id] }] : [])
  account_ids        = distinct(concat(var.account_ids, local.default_account_ids))
  identifiers_list   = [for account_id in local.account_ids : "arn:aws:iam::${account_id}:root"]
  bucket_list        = distinct([for item in var.buckets : "arn:aws:s3:::${split("/", item)[0]}"])
  bucket_path_list   = distinct([for item in var.buckets : "arn:aws:s3:::${item}"])
  s3_tables_resource = distinct([for item in var.s3_tables : endswith(item, "/*") ? "${item}" : "${item}/*"])
  tag_set            = merge({ Vendor = "StreamNative", Module = "StreamNative Volume", SNVersion = var.sn_policy_version }, var.tags)
  init_statement = [
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
  s3_tables_init_statement = [
    {
      "Sid" : "LakeFormationPermissionsForS3ListTableBucket",
      "Effect" : "Allow",
      "Action" : [
        "s3tables:ListTableBuckets"
      ],
      "Resource" : [
        "*"
      ]
    },
    {
      "Sid" : "LakeFormationDataAccessPermissionsForS3TableBucket",
      "Effect" : "Allow",
      "Action" : [
        "s3tables:CreateTableBucket",
        "s3tables:GetTableBucket",
        "s3tables:CreateNamespace",
        "s3tables:GetNamespace",
        "s3tables:ListNamespaces",
        "s3tables:DeleteNamespace",
        "s3tables:DeleteTableBucket",
        "s3tables:CreateTable",
        "s3tables:DeleteTable",
        "s3tables:GetTable",
        "s3tables:ListTables",
        "s3tables:RenameTable",
        "s3tables:UpdateTableMetadataLocation",
        "s3tables:GetTableMetadataLocation",
        "s3tables:GetTableData",
        "s3tables:PutTableData"
      ],
      "Resource" : local.s3_tables_resource
    }
  ]
  s3_tables_statement = length(local.s3_tables_resource) > 0 ? local.s3_tables_init_statement : []
  final_policy = {
    Version   = "2012-10-17"
    Statement = concat(local.init_statement, local.s3_tables_statement)
  }
  default_account_ids = compact([
    # will add it in the next pr
  ])
}


output "test2" {
  value = local.s3_tables_init_statement
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
  name   = var.role
  role   = aws_iam_role.access_bucket_role.id
  policy = jsonencode(local.final_policy)
}

resource "aws_iam_role" "access_bucket_role" {
  name                 = var.role
  description          = "This role is used by StreamNative for the access s3 bucket."
  assume_role_policy   = data.aws_iam_policy_document.streamnative_management_access.json
  path                 = "/StreamNative/"
  tags                 = local.tag_set
  max_session_duration = 43200
}