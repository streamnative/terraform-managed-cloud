terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "1.248.0"
    }
  }
}

variable "privatelink_service_id" {
  description = "The ID of the PrivateLink service, it should be obtained from StreamNative Cloud."
  type        = string
}

variable "domain_name" {
  description = "The domain suffix of the Pulsar endpoint, it should be obtained from StreamNative Cloud."
  type        = string
}

variable "endpoint_name" {
  description = "The name of the VPC endpoint will be created, used to identify from other endpoints."
  type        = string
  default     = "streamnative-pulsar-endpoint"
}

variable "vpc_id" {
  description = "The ID of the VPC to create the endpoint in."
  type        = string
}

variable "vswitches" {
  description = "The list of VSwitches to associate with the endpoint."
  type = list(object({
    id   = string
    zone = string
  }))
}

variable "security_group_ids" {
  description = "The list of security group IDs to associate with the endpoint, will create a new security group if this is empty."
  type        = list(string)
  default     = []
}

variable "security_group_inbound_rules" {
  description = "List of inbound rules for the security group, allowing traffic to the endpoint."
  type = list(object({
    port        = string
    description = string
  }))
  default = [
    {
      port        = "443/443",
      description = "Allow HTTPS traffic to the endpoint"
    },
    {
      port        = "6651/6651",
      description = "Allow Pulsar traffic to the endpoint"
    },
    {
      port        = "9093/9093",
      description = "Allow Kafka traffic to the endpoint"
    },
    {
      port        = "5671/5671",
      description = "Allow AMQP traffic to the endpoint"
    },
    {
      port        = "8883/8883",
      description = "Allow MQTT traffic to the endpoint"
    }
  ]
}
