data "aws_vpc" "this" {
  id = var.vpc_id
}

locals {
  security_group_ids = coalescelist(var.security_group_ids, aws_security_group.this[*].id)

  security_group_rules = {
    ingress_https = {
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65535
      cidr_blocks = data.aws_vpc.this.cidr_block_associations.*.cidr_block
      description = "Allow access from VPC"
    }
    egress_http = {
      type        = "egress"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = data.aws_vpc.this.cidr_block_associations.*.cidr_block
      description = "HTTP to VPC"
    }
    egress_https = {
      type        = "egress"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = data.aws_vpc.this.cidr_block_associations.*.cidr_block
      description = "HTTPS to VPC"
    }
    egress_broker_tls = {
      type        = "egress"
      protocol    = "tcp"
      from_port   = 6651
      to_port     = 6651
      cidr_blocks = data.aws_vpc.this.cidr_block_associations.*.cidr_block
      description = "Broker TLS to VPC"
    }
    egress_kafka_tls = {
      type        = "egress"
      protocol    = "tcp"
      from_port   = 9093
      to_port     = 9093
      cidr_blocks = data.aws_vpc.this.cidr_block_associations.*.cidr_block
      description = "Kafka TLS to VPC"
    }
    egress_amqp_tls = {
      type        = "egress"
      protocol    = "tcp"
      from_port   = 5671
      to_port     = 5671
      cidr_blocks = data.aws_vpc.this.cidr_block_associations.*.cidr_block
      description = "AMQP TLS to VPC"
    }
    egress_mqtt_tls = {
      type        = "egress"
      protocol    = "tcp"
      from_port   = 8883
      to_port     = 8883
      cidr_blocks = data.aws_vpc.this.cidr_block_associations.*.cidr_block
      description = "MQTT TLS to VPC"
    }
    egress_status = {
      type        = "egress"
      protocol    = "tcp"
      from_port   = 15021
      to_port     = 15021
      cidr_blocks = data.aws_vpc.this.cidr_block_associations.*.cidr_block
      description = "Status to VPC"
    }
  }
}

resource "aws_vpc_endpoint" "this" {
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  service_name       = var.service_name
  security_group_ids = local.security_group_ids

  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  auto_accept         = true

  tags = {
    "Name" = coalesce(var.name, var.service_name)
  }
}

resource "aws_security_group" "this" {
  count = var.security_group_ids == null ? 1 : 0

  name_prefix = var.service_name
  vpc_id      = var.vpc_id
  description = "For access vpc endpoint service ${var.service_name}"

  tags = {
    "Name" = var.service_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in local.security_group_rules : k => v if var.security_group_ids == null }

  security_group_id = aws_security_group.this[0].id
  type              = each.value.type
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
}
