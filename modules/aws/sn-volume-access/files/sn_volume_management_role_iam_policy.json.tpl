{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowedIAMReadActions",
      "Effect": "Allow",
      "Action": [
        "iam:GetPolicy*",
        "iam:GetRole*"
      ],
      "Resource": [
        "arn:${partition}:iam::${account_id}:role/StreamNative/*",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/*"
      ]
    },
    {
      "Sid": "IamRequireRequestTag",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:TagPolicy",
        "iam:TagRole"
      ],
      "Resource": [
        "arn:${partition}:iam::${account_id}:role/StreamNative/*",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/*"
      ],
      "Condition": {
        "StringEqualsIgnoreCase": {
          "aws:RequestTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "IamAttach",
      "Effect": "Allow",
      "Action": [
        "iam:AttachRolePolicy"
      ],
      "Resource": "arn:${partition}:iam::${account_id}:role/StreamNative/*"
    },
    {
      "Sid": "s3o",
      "Effect": "Allow",
      "Action": [
          "s3:Get*",
          "s3:ListBucket"
      ],
      "Resource": "arn:${partition}:iam::${account_id}:role/StreamNative/*"
    },
    {
      "Sid": "IamRequireResourceTag",
      "Effect": "Allow",
      "Action": [
        "iam:DeleteRole",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:PutRolePermissionsBoundary",
        "iam:SetDefaultPolicyVersion",
        "iam:UpdateAssumeRolePolicy",
        "iam:UpdateRole",
        "iam:UpdateRoleDescription"
      ],
      "Resource": [
        "arn:${partition}:iam::${account_id}:role/StreamNative/*",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/*"
      ],
      "Condition": {
        "StringEqualsIgnoreCase": {
          "aws:ResourceTag/Vendor": "StreamNative"
        }
      }
    }
  ]
}
