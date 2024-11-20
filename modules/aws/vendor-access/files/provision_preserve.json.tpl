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
      "Sid": "SvcLnkRl",
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "arn:${partition}:iam::${account_id}:role/aws-service-role/*"
    }
  ]
}