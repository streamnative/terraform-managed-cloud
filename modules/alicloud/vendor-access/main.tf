locals {
  account_id = data.alicloud_caller_identity.current.account_id

  # Non-RAM permissions (ECS/VPC/ACK/SLB/DNS/OSS...) for the bootstrap role only.
  base_statements = jsondecode(file("${path.module}/files/access_policy_bootstrap_base.json.tpl")).Statement

  # RAM users created for the DNS integrations (cert-manager / external-dns).
  dns_user_arns = [
    "acs:ram:*:${local.account_id}:user/alidns-webhook-*",
    "acs:ram:*:${local.account_id}:user/external-dns-*",
  ]

  bootstrap_ram_statements = [
    {
      # Read access is needed to verify the Aliyun-managed system roles and policy attachments.
      Effect   = "Allow"
      Action   = ["ram:Get*", "ram:List*"]
      Resource = ["*"]
    },
    {
      Effect   = "Allow"
      Action   = ["ram:CreateServiceLinkedRole", "ram:DeleteServiceLinkedRole"]
      Resource = ["*"]
    },
    {
      Effect = "Allow"
      Action = [
        "ram:CreateUser", "ram:DeleteUser",
        "ram:CreateAccessKey", "ram:DeleteAccessKey", "ram:UpdateAccessKey",
        "ram:AttachPolicyToUser", "ram:DetachPolicyFromUser",
      ]
      Resource = local.dns_user_arns
    },
    {
      # AttachPolicyToUser also evaluates the policy resource; only the DNS system policy.
      Effect   = "Allow"
      Action   = ["ram:AttachPolicyToUser", "ram:DetachPolicyFromUser"]
      Resource = ["acs:ram:*:system:policy/AliyunDNSFullAccess"]
    },
  ]

  # Applies to both roles: block privilege-escalation regardless of Allow statements.
  deny_statements = [
    {
      Effect = "Deny"
      Action = [
        "ram:AttachPolicyToUser", "ram:AttachPolicyToRole", "ram:AttachPolicyToGroup",
      ]
      Resource = [
        "acs:ram:*:system:policy/AdministratorAccess",
        "acs:ram:*:system:policy/AliyunRAMFullAccess",
        "acs:ram:*:system:policy/AliyunSTSAssumeRoleAccess",
      ]
    },
    {
      Effect = "Deny"
      Action = [
        "ram:CreateLoginProfile", "ram:UpdateLoginProfile",
        "ram:CreateRole", "ram:UpdateRole", "ram:DeleteRole",
        "ram:CreatePolicy", "ram:CreatePolicyVersion", "ram:SetDefaultPolicyVersion",
        "ram:DeletePolicy", "ram:DeletePolicyVersion",
        "sts:AssumeRole",
      ]
      Resource = ["acs:ram:*:${local.account_id}:role/streamnative-*", "acs:ram:*:${local.account_id}:policy/streamnative-*"]
    },
  ]

  bootstrap_policy_document = var.read_only_mode ? jsonencode({
    Version   = "1"
    Statement = concat(local.readonly_statements, local.deny_statements)
    }) : jsonencode({
    Version   = "1"
    Statement = concat(local.base_statements, local.bootstrap_ram_statements, local.deny_statements)
  })

  # Strictly read-only across all services. No create/modify/delete actions
  # anywhere. Object-level OSS reads are deliberately excluded. Always used for
  # the support role, and for the bootstrap role when var.read_only_mode is true.
  readonly_statements = [
    {
      Effect = "Allow"
      Action = [
        "ecs:Describe*", "ecs:List*",
        "vpc:Describe*", "vpc:Get*", "vpc:List*",
        "cs:Describe*", "cs:Get*", "cs:List*", "cs:Queryk8sComponentsUpdateVersion",
        "slb:Describe*",
        "nlb:Get*", "nlb:List*",
        "privatelink:Get*", "privatelink:List*",
        "alidns:Describe*", "alidns:Get*", "alidns:List*",
        "pvtz:Describe*",
        "oss:ListBuckets", "oss:GetBucket*",
        "ram:Get*", "ram:List*",
      ]
      Resource = ["*"]
    },
  ]

  # Support is always strictly read-only, regardless of read_only_mode.
  support_policy_document = jsonencode({
    Version   = "1"
    Statement = concat(local.readonly_statements, local.deny_statements)
  })
}

data "alicloud_caller_identity" "current" {
}

data "alicloud_ram_policy_document" "cloud_manager_trust_policy" {
  version = "1"
  statement {
    effect = "Allow"
    action = ["sts:AssumeRole"]
    principal {
      entity      = "RAM"
      identifiers = var.streamnative_cloud_manager_role_arns
    }
    condition {
      operator = "StringEquals"
      variable = "sts:ExternalId"
      values   = var.organization_ids
    }
  }
}

resource "alicloud_ram_policy" "cloud_manager_access" {
  policy_name     = "streamnative-bootstrap"
  description     = "StreamNative cloud manager access policy"
  policy_document = local.bootstrap_policy_document
  force           = true
  rotate_strategy = "DeleteOldestNonDefaultVersionWhenLimitExceeded"
}

resource "alicloud_ram_role" "cloud_manager_role" {
  name        = "streamnative-bootstrap"
  description = "StreamNative cloud manager access role"
  document    = data.alicloud_ram_policy_document.cloud_manager_trust_policy.document
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "cloud_manager_access" {
  policy_name = alicloud_ram_policy.cloud_manager_access.policy_name
  policy_type = alicloud_ram_policy.cloud_manager_access.type
  role_name   = alicloud_ram_role.cloud_manager_role.name
}


data "alicloud_ram_policy_document" "support_role_trust_policy" {
  version = "1"
  statement {
    effect = "Allow"
    action = ["sts:AssumeRole"]
    principal {
      entity      = "RAM"
      identifiers = var.streamnative_support_role_arns
    }
    condition {
      operator = "StringEquals"
      variable = "sts:ExternalId"
      values   = var.organization_ids
    }
  }
}

resource "alicloud_ram_policy" "support_access" {
  policy_name     = "streamnative-support"
  description     = "StreamNative support role access policy"
  policy_document = local.support_policy_document
  force           = true
  rotate_strategy = "DeleteOldestNonDefaultVersionWhenLimitExceeded"
}

resource "alicloud_ram_role" "support_role" {
  name        = "streamnative-support"
  description = "StreamNative support access role"
  document    = data.alicloud_ram_policy_document.support_role_trust_policy.document
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "support_access" {
  policy_name = alicloud_ram_policy.support_access.policy_name
  policy_type = alicloud_ram_policy.support_access.type
  role_name   = alicloud_ram_role.support_role.name
}


// Activate OSS
data "alicloud_oss_service" "open" {
  enable = "On"
}

// Activate ACK
// ref: https://www.alibabacloud.com/help/en/ack/ack-managed-and-ack-dedicated/developer-reference/use-terraform-to-assign-default-roles-to-ack-when-you-use-ack-for-the-first-time
data "alicloud_ack_service" "open" {
  enable = "On"
  type   = "propayasgo"
}

output "account_id" {
  value = data.alicloud_caller_identity.current.account_id
}

output "organization_ids" {
  value = var.organization_ids
}

output "services" {
  value = {
    oss = data.alicloud_oss_service.open.status
    ack = data.alicloud_ack_service.open.status
  }
}
