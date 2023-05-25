{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowedServices",
      "Effect": "Allow",
      "Action": [
        "acm:List*",
        "acm:ImportCertificate",
        "autoscaling:Describe*",
        "cloudwatch:Describe*",
        "cloudwatch:List*",
        "cloudwatch:Get*",
        "ec2:Describe*",
        "ec2:Get*",
        "eks:Describe*",
        "eks:List*",
        "elasticloadbalancing:Describe*",
        "logs:Describe*",
        "logs:List*",
        "logs:Filter*",
        "logs:StartQuery",
        "logs:StopQuery",
        "route53:Get*",
        "route53:List*",
        "support:*",
        "servicequotas:List*",
        "servicequotas:Get*",
        "sts:DecodeAuthorizationMessage"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowedIAMReadActions",
      "Effect": "Allow",
      "Action": [
        "iam:GetPolicy*",
        "iam:GetRole*",
        "iam:ListRole*",
        "iam:ListPolic*"
      ],
      "Resource": [
        "arn:${partition}:iam::${account_id}:role/StreamNative/*",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/*",
        "arn:${partition}:iam::aws:policy/*"
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
      "Resource": "arn:${partition}:iam::${account_id}:role/StreamNative/*",
      "Condition": {
        "ArnEquals": {
          "iam:PolicyARN": [
            "arn:${partition}:iam::${account_id}:policy/StreamNative/StreamNativeCloudRuntimePolicy"
          ]
        }
      }
    },
    {
      "Sid": "IamRequireResourceTag",
      "Effect": "Allow",
      "Action": [
        "iam:DeleteRole",
        "iam:DetachRolePolicy",
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
    },
    {
      "Sid": "RequireResourceTag",
      "Effect": "Allow",
      "Action": [
        "acm:DeleteCertificate",
        "acm:DescribeCertificate",
        "acm:GetCertificate",
        "autoscaling:CancelInstanceRefresh",
        "autoscaling:PutScalingPolicy",
        "autoscaling:ResumeProcesses",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:StartInstanceRefresh",
        "autoscaling:SuspendProcesses",
        "autoscaling:UpdateAutoScalingGroup",
        "eks:UpdateNodegroupConfig",
        "eks:UpdateNodegroupVersion"
      ],
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEqualsIgnoreCase": {
          "aws:ResourceTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "RequireRequestTag",
      "Effect": "Allow",
      "Action": [
        "acm:AddTagsToCertificate",
        "acm:ImportCertificate"
      ],
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEqualsIgnoreCase": {
          "aws:RequestTag/Vendor": "StreamNative"
        }
      }
    }
  ]
}
