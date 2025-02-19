{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RO",
      "Effect": "Allow",
      "Action": [
        "autoscaling:Describe*",
        "ec2:Describe*",
        "ec2:Get*",
        "eks:Describe*",
        "eks:List*",
        "elasticloadbalancing:Describe*",
        "iam:GetInstanceProfile",
        "iam:GetOpenIDConnectProvider",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetRole",
        "iam:List*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ResRlPol",
      "Effect": "Allow",
      "Action": "iam:AttachRolePolicy",
      "Resource": "arn:${partition}:iam::${account_id}:role/StreamNative/*"
    },
    {
      "Sid": "SecGrpVPC",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroup*",
        "ec2:RevokeSecurityGroup*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "ResEKS",
      "Effect": "Allow",
      "Action": [
        "eks:DeleteNode*"
      ],
      "Resource": [
        "arn:${partition}:eks:${region}:${account_id}:nodegroup/${cluster_pattern}/*/*"
      ]
    },
    {
      "Sid": "AsgTags",
      "Effect": "Allow",
      "Action": [
        "autoscaling:*Tags",
        "autoscaling:Delete*"
      ],
      "Resource": [ "*" ],
      "Condition": {
        "StringLike": {
          "autoscaling:ResourceTag/eks:cluster-name": "${cluster_pattern}"
        }
      }
    },
    {
      "Sid": "EC2Tags",
      "Effect": "Allow",
      "Action": [
        "ec2:Associate*",
        "ec2:Delete*",
        "ec2:Disassociate*",
        "ec2:Modify*",
        "ec2:*TransitGateway*"
      ],
      "Resource": [ "*" ],
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "ELBTags",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:De*",
        "elasticloadbalancing:*LoadBalancer*"
      ],
      "Resource": [ "*" ],
      "Condition": {
        "StringLike": {
          "elasticloadbalancing:ResourceTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "AllowTag",
      "Effect": "Allow",
      "Action": [
        "eks:TagResource",
        "eks:UntagResource",
        "eks:AssociateAccessPolicy",
        "eks:DisassociateAccessPolicy",
        "eks:DeleteAccessEntry"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:ResourceTag/cluster-name": "${cluster_pattern}"
        }
      }
    },
    {
      "Sid": "ReqReqTag",
      "Effect": "Allow",
      "Action": [
        "autoscaling:Create*",
        "ec2:*TransitGateway*",
        "ec2:AllocateAddress",
        "ec2:Create*",
        "eks:Create*",
        "eks:RegisterCluster",
        "eks:TagResource",
        "elasticloadbalancing:Add*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "ResPsRlEKS",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": [
        "arn:${partition}:iam::${account_id}:role/StreamNative/*",
        "arn:${partition}:iam::${account_id}:role/${cluster_pattern}"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": "eks.amazonaws.com"
        }
      }
    },
    {
      "Sid": "ReqResrcTag",
      "Effect": "Allow",
      "Action": [
        "autoscaling:AttachInstances",
        "autoscaling:CreateOrUpdateTags",
        "autoscaling:Detach*",
        "autoscaling:Update*",
        "autoscaling:Resume*",
        "autoscaling:Suspend*",
        "autoscaling:SetDesired*",
        "ec2:AttachVolume",
        "ec2:CreateLaunchTemplateVersion",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:Detach*",
        "ec2:Release*",
        "ec2:Revoke*",
        "ec2:TerminateInstances",
        "ec2:Update*",
        "eks:AccessKubernetesApi",
        "eks:DeleteAddon",
        "eks:DeleteCluster",
        "eks:DeleteFargateProfile",
        "eks:DeregisterCluster",
        "eks:U*",
        "elasticloadbalancing:*Listener",
        "elasticloadbalancing:*Rule",
        "elasticloadbalancing:*TargetGroup",
        "elasticloadbalancing:Set*",
        "elasticloadbalancing:Re*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Vendor": "StreamNative"
        }
      }
    },
    {
      "Sid": "IAMReqTag",
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:CreateRole",
        "iam:CreatePolicy*",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:DeleteOpenIDConnectProvider",
        "iam:DeleteRole*",
        "iam:DeleteServiceLinkedRole",
        "iam:DetachRolePolicy",
        "iam:PutRolePermissionsBoundary",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:SetDefaultPolicyVersion",
        "iam:UpdateAssumeRolePolicy",
        "iam:UpdateOpenIDConnectProviderThumbprint",
        "iam:UpdateRole",
        "iam:UpdateRoleDescription",
        "iam:Untag*",
        "iam:CreateOpenIDConnectProvider",
        "iam:Tag*",
        "iam:DeletePolicy",
        "iam:DeletePolicyVersion",
        "iam:PutRolePolicy"
      ],
      "Resource": [
        "arn:${partition}:iam::${account_id}:role/StreamNative/*",
        "arn:${partition}:iam::${account_id}:policy/StreamNative/*",
        "arn:${partition}:iam::${account_id}:oidc-provider/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Vendor": "StreamNative"
        }
      }
    }
  ]
}