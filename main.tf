# Virtual Private Gateway
resource "aws_vpn_gateway" "this" {
  amazon_side_asn = 64512
  tags = {
    Name = "sahinur-vpn-gateway"
  }
}

# Attach VGW to VPC
resource "aws_vpn_gateway_attachment" "this" {
  vpc_id         = var.vpc_id
  vpn_gateway_id = aws_vpn_gateway.this.id
}

# Customer Gateway
resource "aws_customer_gateway" "this" {
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name = "sahinur-customer-gateway"
  }
}

# VPN Connection
resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = aws_customer_gateway.this.id
  type                = var.vpn_connection_type
  static_routes_only  = length(var.vpn_static_routes) > 0 ? true : false

  tags = {
    Name = "sahinur-vpn-connection"
  }
}

# VPN Static Routes (optional, only if using static routing)
resource "aws_vpn_connection_route" "static_routes" {
  for_each = { for cidr in var.vpn_static_routes : cidr => cidr }

  vpn_connection_id = aws_vpn_connection.this.id
  destination_cidr_block = each.key
}
# ========== Fetch Route Tables & Add Route Propagation==========
data "aws_route_tables" "this" {
  vpc_id = var.vpc_id
}

resource "aws_vpn_gateway_route_propagation" "this" {
  for_each       = toset(data.aws_route_tables.this.ids)
  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = each.value
}
