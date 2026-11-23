{
  "Version": "1",
  "Statement": [
    {
      "Action": [
        "ecs:Describe*",
        "ecs:List*",
        "ecs:AddTags",
        "ecs:AttachDisk",
        "ecs:AttachNetworkInterface",
        "ecs:AttachVolume",
        "ecs:AuthorizeSecurityGroup",
        "ecs:CreateDisk",
        "ecs:CreateLaunchTemplate",
        "ecs:CreateLaunchTemplateVersion",
        "ecs:CreateNetworkInterface",
        "ecs:CreateSecurityGroup",
        "ecs:CreateVolume",
        "ecs:DeleteDisk",
        "ecs:DeleteLaunchTemplate",
        "ecs:DeleteLaunchTemplateVersion",
        "ecs:DeleteNetworkInterface",
        "ecs:DeleteSecurityGroup",
        "ecs:DeleteVolume",
        "ecs:DetachDisk",
        "ecs:DetachNetworkInterface",
        "ecs:DetachVolume",
        "ecs:ModifyDiskAttribute",
        "ecs:ModifyDiskSpec",
        "ecs:ModifyInstance*",
        "ecs:ModifyLaunchTemplateDefaultVersion",
        "ecs:ModifyNetworkInterfaceAttribute",
        "ecs:ModifySecurityGroup*",
        "ecs:RebootInstance",
        "ecs:ResizeDisk",
        "ecs:StartInstance",
        "ecs:StartInstances",
        "ecs:StopInstance",
        "ecs:StopInstances",
        "ecs:TagResources",
        "ecs:UntagResources"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Action": [
        "vpc:Get*",
        "vpc:List*",
        "vpc:Create*",
        "vpc:Describe*",
        "vpc:Modify*",
        "vpc:Allocate*",
        "vpc:AssociateEipAddress",
        "vpc:AssociateRouteTable",
        "vpc:Release*",
        "vpc:Unassociate*",
        "vpc:DeleteRouteEntry",
        "vpc:DeleteRouteTable",
        "vpc:DeleteRouterInterface",
        "vpc:DeleteVSwitch",
        "vpc:DeleteVpc",
        "vpc:DeleteNatGateway",
        "vpc:DeleteSnatEntry",
        "vpc:TagResources"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cs:Get*",
        "cs:List*",
        "cs:Cancel*",
        "cs:Create*",
        "cs:Describe*",
        "cs:AttachInstances",
        "cs:DeleteCluster",
        "cs:DeleteClusterNodepool",
        "cs:DeleteClusterNodes",
        "cs:DeletePolicyInstance",
        "cs:DeleteTemplate",
        "cs:DeployPolicyInstance",
        "cs:*ClusterAddons",
        "cs:ModifyCluster",
        "cs:ModifyClusterAddon",
        "cs:ModifyClusterConfiguration",
        "cs:ModifyClusterNodePool",
        "cs:ModifyClusterTags",
        "cs:ModifyPolicyInstance",
        "cs:PauseClusterUpgrade",
        "cs:PauseComponentUpgrade",
        "cs:QueryK8sComponentUpgradeStatus",
        "cs:Queryk8sComponentsUpdateVersion",
        "cs:RemoveClusterNodes",
        "cs:ResumeComponentUpgrade",
        "cs:ResumeUpgradeCluster",
        "cs:ScaleCluster",
        "cs:ScaleClusterNodePool",
        "cs:ScaleOutCluster",
        "cs:UnInstallK8sComponents",
        "cs:UpdateK8sClusterUserConfigExpire",
        "cs:UpdateTemplate",
        "cs:UpdateUserPermissions",
        "cs:UpgradeCluster",
        "cs:UpgradeK8sComponents"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "nlb:*",
        "slb:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "privatelink:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "alidns:Get*",
        "alidns:List*",
        "alidns:Describe*",
        "alidns:AddDomain",
        "alidns:AddDomainRecord",
        "alidns:DeleteDomain",
        "alidns:DeleteDomainRecord",
        "alidns:RetrieveDomain",
        "alidns:Update*",
        "alidns:Set*",
        "alidns:BindInstanceDomains",
        "alidns:UnbindInstanceDomains",
        "alidns:*",
        "pvtz:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "alidns:Get*",
        "alidns:List*",
        "alidns:Describe*",
        "alidns:AddDomain",
        "alidns:AddDomainRecord",
        "alidns:DeleteDomain",
        "alidns:DeleteDomainRecord",
        "alidns:RetrieveDomain",
        "alidns:Update*",
        "alidns:Set*",
        "alidns:BindInstanceDomains",
        "alidns:UnbindInstanceDomains",
        "pvtz:*",
        "bss:ModifyInstance"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "oss:Get*",
        "oss:List*",
        "oss:Delete*",
        "oss:Put*",
        "oss:Restore*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
