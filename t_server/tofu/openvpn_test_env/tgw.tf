locals {
  attach_transit_gateway = var.transit_gateway_id != ""
}

# Attach the primary VPC to an existing Transit Gateway so the test instances
# can reach resources in peered VPCs (e.g. the buildbot master). The attachment
# uses the primary public subnet, which is the only subnet available in both
# managed and external (manage_vpc = false) VPC modes.
resource "aws_ec2_transit_gateway_vpc_attachment" "primary" {
  count = local.attach_transit_gateway ? 1 : 0

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = local.primary_vpc_id
  subnet_ids         = [local.primary_vpc_primary_public_subnet_id]

  tags = {
    Name = "${var.deployment}-tgw-attachment"
  }
}

# Routes for resources reachable over the TGW, added to the public route table
# (where the test instances live).
resource "aws_route" "transit_gateway_public_ipv4" {
  for_each = local.attach_transit_gateway ? toset(var.transit_gateway_destination_cidr_blocks) : toset([])

  route_table_id         = local.primary_vpc_primary_public_subnet_route_table_id
  destination_cidr_block = each.value
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.primary]
}

resource "aws_route" "transit_gateway_public_ipv6" {
  for_each = local.attach_transit_gateway ? toset(var.transit_gateway_destination_ipv6_cidr_blocks) : toset([])

  route_table_id              = local.primary_vpc_primary_public_subnet_route_table_id
  destination_ipv6_cidr_block = each.value
  transit_gateway_id          = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.primary]
}

# The private route table only exists when we manage the VPC.
resource "aws_route" "transit_gateway_private_ipv4" {
  for_each = local.attach_transit_gateway && var.manage_vpc ? toset(var.transit_gateway_destination_cidr_blocks) : toset([])

  route_table_id         = module.primary-vpc[0].private_route_table_id
  destination_cidr_block = each.value
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.primary]
}

resource "aws_route" "transit_gateway_private_ipv6" {
  for_each = local.attach_transit_gateway && var.manage_vpc ? toset(var.transit_gateway_destination_ipv6_cidr_blocks) : toset([])

  route_table_id              = module.primary-vpc[0].private_route_table_id
  destination_ipv6_cidr_block = each.value
  transit_gateway_id          = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.primary]
}
