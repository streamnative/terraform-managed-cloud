{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowedServices",
      "Effect": "Allow",
      "Action": [
          "acm:*",
          "autoscaling:*",
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
          "route53:*",
          "s3:*",
          "servicequotas:*",
          "shield:*",
          "support:*",
          "sts:*",
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
        "iam:DeleteInstanceProfile",
        "iam:DeleteOpenIDConnectProvider",
        "iam:DeletePolicy*",
        "iam:DeleteRole",
        "iam:DeleteServiceLinkedRole",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:PutRolePermissionsBoundary",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:SetDefaultPolicyVersion",
        "iam:Tag*"
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
      "Sid": "RestrictPassRoleToEKS",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": [
        "arn:${partition}:iam::${account_id}:role/${cluster_pattern}",
        "arn:${partition}:iam::${account_id}:role/StreamNative/${cluster_pattern}"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": "eks.amazonaws.com"
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
