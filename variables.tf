variable "vpc_id" {
  description = "The ID of the VPC to attach the VGW to"
  type        = string
}

variable "customer_gateway_ip" {
  description = "Public IP address of the customer gateway device"
  type        = string
}

variable "customer_gateway_bgp_asn" {
  description = "BGP ASN for the customer gateway"
  type        = number
  default     = 65000
}

variable "vpn_connection_type" {
  description = "Type of VPN connection"
  type        = string
  default     = "ipsec.1"
}

variable "vpn_static_routes" {
  description = "List of CIDR blocks for static routes (if not using BGP)"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS Region for the VPN configuration"
  type        = string
}

variable "access_key" {
  description = "Access Keys"
  type        = string
}

variable "secret_key" {
  description = "Secret Key"
  type        = string
}
