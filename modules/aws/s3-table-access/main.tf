data "aws_caller_identity" "current" {}
locals {
  s3_tables_resource = distinct(var.s3_tables)
  s3_tables_path_resource = distinct([for item in local.s3_tables_resource : "${item}/*"])
  tag_set            = merge({ Vendor = "StreamNative", Module = "StreamNative S3 Table Access", SNVersion = var.sn_policy_version }, var.tags)
}

######
#-- Create the IAM role inline policy for the the StreamNative Cloud access to s3 table
######
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "${var.role}-s3-table"
  role = var.role
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
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
          "s3tables:GetTableBucket",
          "s3tables:CreateNamespace",
          "s3tables:GetNamespace",
          "s3tables:ListNamespaces",
          "s3tables:CreateTable",
          "s3tables:GetTable",
          "s3tables:ListTables",
          "s3tables:UpdateTableMetadataLocation",
          "s3tables:GetTableMetadataLocation",
          "s3tables:GetTableData",
          "s3tables:PutTableData"
        ],
        "Resource" : concat(local.s3_tables_resource, local.s3_tables_path_resource)
      }
    ]
  })
}