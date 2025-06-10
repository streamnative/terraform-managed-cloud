resource "alicloud_security_group" "new" {
  count = var.use_existing_security_group ? 0 : 1

  security_group_name = "${var.endpoint_name}-pl-sg"
  vpc_id              = var.vpc_id
  description         = "Security group for PrivateLink VPC Endpoint ${var.endpoint_name}"
}

resource "alicloud_security_group_rule" "new" {
  count = var.use_existing_security_group ? 0 : length(var.security_group_inbound_rules)

  security_group_id = alicloud_security_group.new[0].id
  type              = "ingress"
  ip_protocol       = "tcp"
  cidr_ip           = "0.0.0.0/0"
  port_range        = var.security_group_inbound_rules[count.index].port
  policy            = "accept"
  description       = var.security_group_inbound_rules[count.index].description
}


locals {
  security_group_ids = var.use_existing_security_group ? var.security_group_ids : [alicloud_security_group.new[0].id]
}


resource "alicloud_privatelink_vpc_endpoint" "this" {
  service_id         = var.privatelink_service_id
  security_group_ids = local.security_group_ids
  vpc_id             = var.vpc_id
  vpc_endpoint_name  = var.endpoint_name

  lifecycle {
    precondition {
      condition     = length(local.security_group_ids) > 0
      error_message = "At least one security group must be provided or created."
    }
  }
}

resource "alicloud_privatelink_vpc_endpoint_zone" "this" {
  count = length(var.vswitches)

  endpoint_id = alicloud_privatelink_vpc_endpoint.this.id
  vswitch_id  = var.vswitches[count.index].id
  zone_id     = var.vswitches[count.index].zone
}

resource "alicloud_pvtz_zone" "this" {
  zone_name = var.domain_name
  remark    = "PrivateLink-${var.endpoint_name}"
}

resource "alicloud_pvtz_zone_attachment" "this" {
  zone_id = alicloud_pvtz_zone.this.id
  vpc_ids = [var.vpc_id]
}

resource "alicloud_pvtz_zone_record" "this" {
  count = length(var.vswitches)

  zone_id = alicloud_pvtz_zone.this.id
  rr      = "*"
  type    = "A"
  value   = alicloud_privatelink_vpc_endpoint_zone.this[count.index].eni_ip
  ttl     = 600
}
