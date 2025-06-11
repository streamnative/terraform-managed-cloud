locals {
  access_policy_document = templatefile("${path.module}/files/access_policy.json.tpl", {
    account_id = data.alicloud_caller_identity.current.account_id
    region     = var.region
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
  policy_document = local.access_policy_document
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
  policy_document = local.access_policy_document
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
