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
        "iam:List*",
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
      "Sid": "RunInst",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": "*",
      "Condition": {
        "ArnLikeIfExists": {
          "ec2:Vpc": ${vpc_ids}
        }
      }
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
          "autoscaling:ResourceTag/cluster-name": "${cluster_pattern}"
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
        "eks:UntagResource"
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
        "acm:AddTagsToCertificate",
        "acm:ImportCertificate",
        "acm:RemoveTagsFromCertificate",
        "acm:RequestCertificate",
        "autoscaling:Create*",
        "ec2:*TransitGateway*",
        "ec2:AllocateAddress",
        "ec2:Create*",
        "eks:Create*",
        "eks:RegisterCluster",
        "eks:TagResource",
        "elasticloadbalancing:Add*",
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
        "autoscaling:AttachInstances",
        "autoscaling:CreateOrUpdateTags",
        "autoscaling:Detach*",
        "autoscaling:Update*",
        "autoscaling:Resume*",
        "autoscaling:Suspend*",
        "autoscaling:SetDesired*",
        "ec2:AssignPrivateIpAddresses",
        "ec2:AttachInternetGateway",
        "ec2:AttachVolume",
        "ec2:CreateLaunchTemplateVersion",
        "ec2:CreateNatGateway",
        "ec2:CreateNetworkInterface",
        "ec2:CreateRoute",
        "ec2:CreateRouteTable",
        "ec2:ReplaceRoute",
        "ec2:ReplaceRouteTableAssociation",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSubnet",
        "ec2:CreateTags",
        "ec2:CreateVpcEndpoint",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:CreateVpcPeeringConnection",
        "ec2:DeleteVpcPeeringConnection",
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
        "elasticloadbalancing:Re*",
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
      "Sid": "AcceptVpcPeering",
      "Effect": "Allow",
      "Action": [
        "ec2:AcceptVpcPeeringConnection"
      ],
      "Resource": "*"
    },
    {
      "Sid": "EndpointConnectionAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:*VpcEndpointConnections"
      ],
      "Resource": "*"
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
      "Sid": "IAMReqTag",
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:CreateRole",
        "iam:CreatePolicy*",
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
    },
    {
      "Sid": "SvcLnkRl",
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "arn:${partition}:iam::${account_id}:role/aws-service-role/*"
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
    }
  ]
}
