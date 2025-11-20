# Get information about the external primary VPC when manage_vpc is false
data "aws_vpc" "primary" {
  count = var.manage_vpc ? 0 : 1
  id    = var.external_primary_vpc_id
}
