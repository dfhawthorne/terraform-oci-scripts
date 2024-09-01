# ------------------------------------------------------------------------------
# OCI CAA Lab 04:
# Configure Local Virtual Cloud Network (VCN) Peering 
# Create VCN 01
# ------------------------------------------------------------------------------

# Virtual Cloud Network resource block
resource "oci_core_vcn" "FRA-AA-LAB04-1-VCN-01" {
    compartment_id        = var.compartment_id
    display_name          = "FRA-AA-LAB04-1-VCN-01"
    cidr_blocks           = ["172.16.0.0/16"]
    dns_label             = "fraaalab04vcn01"
}

resource "oci_core_nat_gateway" "NAT-gateway-FRA-AA-LAB04-1-VCN-01" {
  block_traffic     = "false"
  compartment_id    = var.compartment_id
  display_name      = "NAT gateway-FRA-AA-LAB04-1-VCN-01"
  vcn_id            = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.id
}

resource "oci_core_internet_gateway" "Internet-gateway-FRA-AA-LAB04-1-VCN-01" {
  compartment_id    = var.compartment_id
  display_name      = "Internet gateway-FRA-AA-LAB04-1-VCN-01"
  enabled           = "true"
  vcn_id            = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.id
}

resource "oci_core_local_peering_gateway" "FRA-AA-LAB04-1-LPG-01" {
    compartment_id  = var.compartment_id
    vcn_id          = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.id
    display_name    = "Local Peering Gateway-FRA-AA-LAB04-1-VCN-01"
    peer_id         = oci_core_local_peering_gateway.FRA-AA-LAB04-1-LPG-02.id
}

resource "oci_core_default_dhcp_options" "DHCP-Options-for-FRA-AA-LAB04-1-VCN-01" {
  manage_default_resource_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.default_dhcp_options_id
  compartment_id    = var.compartment_id
  display_name      = "DHCP Options for FRA-AA-LAB04-1-VCN-01"
  domain_name_type  = "CUSTOM_DOMAIN"
  options {
    custom_dns_servers  = [
    ]
    server_type         = "VcnLocalPlusInternet"
    type                = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "fraaalab04vcn01.oraclevcn.com",
    ]
    type = "SearchDomain"
  }
}

resource "oci_core_subnet" "public-subnet-FRA-AA-LAB04-1-VCN-01" {
  cidr_block     = "172.16.0.0/24"
  compartment_id = var.compartment_id
  display_name    = "public subnet-FRA-AA-LAB04-1-VCN-01"
  dns_label       = "sub07051559030"
  ipv6cidr_blocks = [
  ]
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.id
}

resource oci_core_subnet private-subnet-FRA-AA-LAB04-1-VCN-01 {
  cidr_block     = "172.16.1.0/24"
  compartment_id = var.compartment_id
  display_name    = "private subnet-FRA-AA-LAB04-1-VCN-01"
  dns_label       = "sub07051559031"
  ipv6cidr_blocks = [
  ]
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.route-table-for-private-subnet-FRA-AA-LAB04-1-VCN-01.id
  security_list_ids = [
    oci_core_security_list.security-list-for-private-subnet-FRA-AA-LAB04-1-VCN-01.id,
  ]
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.id
}

resource oci_core_route_table route-table-for-private-subnet-FRA-AA-LAB04-1-VCN-01 {
  compartment_id = var.compartment_id
  display_name = "route table for private subnet-FRA-AA-LAB04-1-VCN-01"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.NAT-gateway-FRA-AA-LAB04-1-VCN-01.id
  }
  route_rules {
    destination       = "all-fra-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.Service-gateway-FRA-AA-LAB04-1-VCN-01.id
  }
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.id
}

resource oci_core_default_route_table default-route-table-for-FRA-AA-LAB04-1-VCN-01 {
  compartment_id              = var.compartment_id
  manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.default_route_table_id
  display_name                = "Default Route Table for FRA-AA-LAB04-1-VCN-01"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.Internet-gateway-FRA-AA-LAB04-1-VCN-01.id
  }
  route_rules {
    destination         = "192.168.0.0/24"
    destination_type    = "CIDR_BLOCK"
    network_entity_id   = oci_core_local_peering_gateway.FRA-AA-LAB04-1-LPG-01.id
  }
}


resource oci_core_security_list security-list-for-private-subnet-FRA-AA-LAB04-1-VCN-01 {
  compartment_id = var.compartment_id
  display_name = "security list for private subnet-FRA-AA-LAB04-1-VCN-01"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "172.16.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "172.16.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.id
}

resource oci_core_default_security_list Default-Security-List-for-FRA-AA-LAB04-1-VCN-01 {
  compartment_id = var.compartment_id
  display_name = "Default Security List for FRA-AA-LAB04-1-VCN-01"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "172.16.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "8"
    }
    protocol    = "1"
    source      = "192.168.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  manage_default_resource_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.default_security_list_id
}

resource oci_core_service_gateway Service-gateway-FRA-AA-LAB04-1-VCN-01 {
  compartment_id = var.compartment_id
  display_name = "Service gateway-FRA-AA-LAB04-1-VCN-01"
  services {
    service_id = "ocid1.service.oc1.eu-frankfurt-1.aaaaaaaalblrg4eycfxwohulzwwq63btwptzs2hva3muxfan5ro5x7glehtq"
  }
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-01.id
}

