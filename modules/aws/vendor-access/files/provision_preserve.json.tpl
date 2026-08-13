{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "UnResRW",
      "Effect": "Allow",
      "Action": [
        "kms:CreateAlias",
        "kms:DeleteAlias",
        "kms:ScheduleKeyDeletion",
        "logs:CreateLogGroup",
        "logs:PutRetentionPolicy",
        "route53:CreateHostedZone",
        "route53:ChangeTagsForResource",
        "support:*",
        "servicequotas:List*",
        "servicequotas:Get*",
        "sts:DecodeAuthorizationMessage"
      ],
      "Resource": "*"
    },
    {
      "Sid": "RO",
      "Effect": "Allow",
      "Action": [
        "acm:ImportCertificate",
        "acm:ListCertificates",
        "acm:ListTagsForCertificate",
        "kms:DescribeKey",
        "kms:GetKeyPolicy",
        "kms:GetKeyRotationStatus",
        "kms:ListAliases",
        "kms:ListResourceTags",
        "logs:Describe*",
        "logs:List*",
        "route53:Get*",
        "route53:List*",
        "rds:DescribeDBInstances",
        "rds:DescribeDBSnapshots",
        "rds:DescribeDBSubnetGroups",
        "rds:ListTagsForResource",
        "s3:ListAllMyBuckets",
        "s3:ListBucket"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ResR53Z",
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:DeleteHostedZone"
      ],
      "Resource": ${r53_zone_arns}
    },
    {
      "Sid": "ReqReqTag",
      "Effect": "Allow",
      "Action": [
        "acm:AddTagsToCertificate",
        "acm:ImportCertificate",
        "acm:RemoveTagsFromCertificate",
        "acm:RequestCertificate",
        "kms:CreateKey",
        "kms:TagResource"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "ReqResrcTag",
      "Effect": "Allow",
      "Action": [
        "acm:DeleteCertificate",
        "acm:DescribeCertificate",
        "acm:ExportCertificate",
        "acm:GetCertificate",
        "acm:ImportCertificate",
        "acm:RemoveTagsFromCertificate",
        "acm:ResendValidationEmail",
        "logs:*",
        "ssm:StartSession"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "SSMStop",
      "Effect": "Allow",
      "Action": [
        "ssm:TerminateSession",
        "ssm:ResumeSession"
      ],
      "Resource": ["arn:aws:ssm:*:*:session/$${aws:username}-*"]
    },
    {
      "Sid": "SQLWorkspaceRDSCreateInstance",
      "Effect": "Allow",
      "Action": "rds:CreateDBInstance",
      "Resource": [
        "arn:${partition}:rds:${region}:${account_id}:db:rw-*-sqlworkspace-*",
        "arn:${partition}:rds:${region}:${account_id}:og:default*",
        "arn:${partition}:rds:${region}:${account_id}:pg:default*",
        "arn:${partition}:rds:${region}:${account_id}:subgrp:rw-*-sqlworkspace-*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/Vendor": "StreamNative",
          "rds:DatabaseEngine": "postgres"
        },
        "Bool": {
          "rds:PubliclyAccessible": "false",
          "rds:StorageEncrypted": "true"
        }
      }
    },
    {
      "Sid": "SQLWorkspaceRDSCreateSubnetGroup",
      "Effect": "Allow",
      "Action": "rds:CreateDBSubnetGroup",
      "Resource": "arn:${partition}:rds:${region}:${account_id}:subgrp:rw-*-sqlworkspace-*",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "SQLWorkspaceRDSManage",
      "Effect": "Allow",
      "Action": [
        "rds:DeleteDBInstance",
        "rds:DeleteDBSubnetGroup",
        "rds:ModifyDBInstance",
        "rds:ModifyDBSubnetGroup",
        "rds:RemoveTagsFromResource"
      ],
      "Resource": [
        "arn:${partition}:rds:${region}:${account_id}:db:rw-*-sqlworkspace-*",
        "arn:${partition}:rds:${region}:${account_id}:subgrp:rw-*-sqlworkspace-*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "SQLWorkspaceRDSFinalSnapshot",
      "Effect": "Allow",
      "Action": [
        "rds:AddTagsToResource",
        "rds:CreateDBSnapshot"
      ],
      "Resource": [
        "arn:${partition}:rds:${region}:${account_id}:db:rw-*-sqlworkspace-*",
        "arn:${partition}:rds:${region}:${account_id}:snapshot:rw-*-sqlworkspace-*-final-*",
        "arn:${partition}:rds:${region}:${account_id}:subgrp:rw-*-sqlworkspace-*"
      ]
    },
    {
      "Sid": "ResS3",
      "Effect": "Allow",
      "Action":[
        "s3:CreateBucket",
        "s3:Delete*",
        "s3:Get*",
        "s3:List*",
        "s3:PutBucket*",
        "s3:PutObject*",
        "s3:PutLifecycle*",
        "s3:PutAccelerateConfiguration",
        "s3:PutAccessPointPolicy",
        "s3:PutAccountPublicAccessBlock",
        "s3:PutAnalyticsConfiguration",
        "s3:PutEncryptionConfiguration"
       ],
       "Resource": [
          "arn:${partition}:s3:::${bucket_pattern}"
       ]
    },
    {
      "Sid": "SQLWorkspaceS3Bucket",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetAccelerateConfiguration",
        "s3:GetBucket*",
        "s3:GetEncryptionConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:GetReplicationConfiguration",
        "s3:ListBucket",
        "s3:ListBucketVersions",
        "s3:PutBucketAcl",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketTagging",
        "s3:PutBucketVersioning",
        "s3:PutEncryptionConfiguration"
      ],
      "Resource": "arn:${partition}:s3:::rw-*-${account_id}-${region}-*"
    },
    {
      "Sid": "SQLWorkspaceS3Objects",
      "Effect": "Allow",
      "Action": [
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": "arn:${partition}:s3:::rw-*-${account_id}-${region}-*/*"
    },
    {
      "Sid": "SvcLnkRl",
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "arn:${partition}:iam::${account_id}:role/aws-service-role/*"
    }
  ]
}
