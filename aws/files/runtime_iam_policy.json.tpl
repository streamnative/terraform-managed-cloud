{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ro",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecrets",
                "route53:ListTagsForResource",
                "route53:ListResourceRecordSets",
                "route53:ListHostedZones*",
                "route53:GetChange",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "ec2:DescribeSnapshots",
                "autoscaling:Describe*"
            ],
            "Resource": ["*"]
        },
        {
            "Sid": "r53sc",
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": ${r53_zone_arns}
        },
        {
            "Sid": "asg",
            "Effect": "Allow",
            "Action": [
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:SetDesiredCapacity"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "autoscaling:ResourceTag/eks:cluster-name": "${cluster_pattern}"
                }
            }
        },
        {
            "Sid": "csik1",
            "Effect": "Allow",
            "Action": [
                "kms:RevokeGrant",
                "kms:ListGrants",
                "kms:CreateGrant"
            ],
            "Resource": [ ${kms_arns} ],  
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": [
                        "true"
                    ]
                }
            }
        },
        {
            "Sid": "csik2",
            "Effect": "Allow",
            "Action": [
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Encrypt",
                "kms:DescribeKey",
                "kms:Decrypt"
            ],
            "Resource": [ ${kms_arns} ]  
        },
        {
            "Sid": "s3b",
            "Effect": "Allow",
            "Action": [
                "s3:ListMultipart*",
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::${bucket_pattern}"
        },
        {
            "Sid": "s3o",
            "Effect": "Allow",
            "Action": [
                "s3:Put*",
                "s3:List*",
                "s3:*Object",
                "s3:*Multipart*"
            ],
            "Resource": "arn:aws:s3:::${bucket_pattern}"  
        },
        {
            "Sid": "vbc",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVolume",
                "ec2:CreateSnapshot"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/kubernetes.io/cluster/${cluster_pattern}": [
                        "owned"
                    ]
                }
            }
        },
        {
            "Sid": "vbt",
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:snapshot/*"
            ],
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": [
                        "CreateVolume",
                        "CreateSnapshot"
                    ]
                }
            }
        },
        {
            "Sid": "vbd",
            "Effect": "Allow",
            "Action": "ec2:DeleteSnapshot",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "aws:ResourceTag/kubernetes.io/cluster/${cluster_pattern}": [
                        "owned"
                    ]
                }
            }
        }
    ]
}