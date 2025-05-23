{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowedServices",
      "Effect": "Allow",
      "Action": [
          "acm:*",
          "autoscaling:*",
          "cloudwatch:*",
          "cognito-idp:*",
          "dynamodb:*",
          "ec2:*",
          "ecr:*",
          "eks:*",
          "elasticloadbalancing:*",
          "iam:Get*",
          "iam:List*",
          "kms:*",
          "logs:*",
          "pricing:*",
          "route53:*",
          "route53domains:*",
          "s3:*",
          "s3tables:*",
          "servicequotas:*",
          "shield:*",
          "sqs:*",
          "ssm:*",
          "sts:*",
          "support:*",
          "waf-regional:*",
          "wafv2:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IamRestrictions",
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:CreateOpenIDConnectProvider",
        "iam:CreateServiceLinkedRole",
        "iam:CreatePolicy*",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:DeleteOpenIDConnectProvider",
        "iam:DeletePolicy*",
        "iam:DeleteRole",
        "iam:DeleteServiceLinkedRole",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:PutRolePermissionsBoundary",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:SetDefaultPolicyVersion",
        "iam:Tag*",
        "iam:Untag*",
        "iam:UpdateAssumeRolePolicy",
        "iam:UpdateOpenIDConnectProviderThumbprint",
        "iam:UpdateRole",
        "iam:UpdateRoleDescription"
      ],
      "Resource": [
        "arn:${partition}:iam::aws:policy/*",
        "arn:${partition}:iam::${account_id}:role/aws-service-role/*",
        "arn:${partition}:iam::${account_id}:role/StreamNative/*",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/*",
        "arn:${partition}:iam::${account_id}:oidc-provider/*",
        "arn:${partition}:iam::${account_id}:instance-profile/*",
        "arn:${partition}:iam::${account_id}:server-certificate/*"
      ]
    },
    {
      "Sid": "AllowedIAMManagedPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:AttachRolePolicy"
      ],
      "Resource": "arn:${partition}:iam::${account_id}:role/StreamNative/*",
      "Condition": {
        "ForAnyValue:ArnLike": {
          "iam:PolicyARN": [ ${allowed_iam_policies} ]
        }
      }
    },
    {
      "Sid": "RequirePermissionBoundaryForIamRoles",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole"
      ],
      "Resource": "arn:${partition}:iam::${account_id}:role/StreamNative/*",
      "Condition": {
        "StringEquals": {
          "iam:PermissionsBoundary": "arn:${partition}:iam::${account_id}:policy/StreamNative/StreamNativeCloudPermissionBoundary"
        }
      }
    },
    {
      "Sid": "RestrictPassRole",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": [
        "arn:${partition}:iam::${account_id}:role/${cluster_pattern}",
        "arn:${partition}:iam::${account_id}:role/StreamNative/*"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "eks.amazonaws.com"
          ]
        }
      }
    },
    {
      "Sid": "RestrictChangesToVendorAccess",
      "Effect": "Deny",
      "Action": [
        "iam:Create*",
        "iam:Delete*",
        "iam:Put*",
        "iam:Tag*",
        "iam:Untag*",
        "iam:Update*",
        "iam:Set*"
      ],
      "Resource": [
        "arn:${partition}:iam::${account_id}:policy/StreamNative/StreamNativeCloudBootstrapPolicy",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/StreamNativeCloudLBPolicy",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/StreamNativeCloudManagementPolicy",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/StreamNativeCloudPermissionBoundary",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/StreamNativeCloudRuntimePolicy",
        "arn:${partition}:iam::${account_id}:role/StreamNative/StreamNativeCloudBootstrapRole",
        "arn:${partition}:iam::${account_id}:role/StreamNative/StreamNativeCloudManagementRole"
      ]
    }
  ]
}
