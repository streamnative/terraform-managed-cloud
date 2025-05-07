locals {
  access_policy_document = templatefile("${path.module}/files/access_policy.json.tpl", {
    account_id = data.alicloud_caller_identity.current.account_id
    region     = var.region
  })
}

data "alicloud_caller_identity" "current" {
}

data "alicloud_ram_policy_document" "support_role_trust_policy" {
  version = "1"
  statement {
    effect = "Allow"
    action = ["sts:AssumeRole"]
    principal {
      entity        = "RAM"
      identifiers = var.streamnative_support_access_role_arns
    }
    condition {
      operator = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.organization_id]
    }
  }
}

resource "alicloud_ram_policy" "support_access" {
  policy_name     = "StreamNativeSupportAccess"
  description     = "StreamNative support access policy"
  policy_document = local.access_policy_document
  force           = true
  rotate_strategy = "DeleteOldestNonDefaultVersionWhenLimitExceeded"
}

resource "alicloud_ram_role" "support_access_role" {
  name        = "StreamNativeSupportAccessRole"
  description = "StreamNative support access role"
  document    = data.alicloud_ram_policy_document.support_role_trust_policy.document
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "support_access" {
  policy_name = alicloud_ram_policy.support_access.policy_name
  policy_type = alicloud_ram_policy.support_access.type
  role_name   = alicloud_ram_role.support_access_role.name
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

output "organization_id" {
  value = var.organization_id
}


# data "alicloud_ram_roles" "roles" {
#     policy_type = "Custom"
#     name_regex  = "^Aliyun.*Role$"
# }

# locals {
#   all_role_names = [for role in var.buildin_roles : role.name]
#   created_role_names  = [for role in data.alicloud_ram_roles.roles.roles : role.name]
#   complement_names = setsubtract(local.all_role_names, local.created_role_names)
#   complement_roles = [for role in var.buildin_roles : role if contains(local.complement_names, role.name)]
# }

# resource "alicloud_ram_role" "role" {
#   for_each    = { for r in local.complement_roles : r.name => r }
#   name        = each.value.name
#   document    = each.value.policy_document
#   description = each.value.description
#   force       = false
# }

# resource "alicloud_ram_role_policy_attachment" "attach" {
#   for_each    = { for r in local.complement_roles : r.name => r }
#   policy_name = each.value.policy_name
#   policy_type = "System"
#   role_name   = each.value.name
#   depends_on  = [alicloud_ram_role.role]
# }


# output "complement_roles" {
#   value = [for role in var.buildin_roles : {
#     name        = role.name
#     description = role.description
#   }]
# }
