
resource "alicloud_privatelink_vpc_endpoint" "this" {
  service_id         = var.privatelink_service_id
  security_group_ids = var.security_group_ids
  vpc_id             = var.vpc_id
  vpc_endpoint_name  = var.endpoint_name
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
  rr = "*"
  type   = "A"
  value  = alicloud_privatelink_vpc_endpoint_zone.this[count.index].eni_ip
  ttl    = 600
}