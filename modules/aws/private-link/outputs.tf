output "vpc_endpoint_arn" {
  value = aws_vpc_endpoint.this.arn
}

output "vpc_endpoint_state" {
  value = aws_vpc_endpoint.this.state
}