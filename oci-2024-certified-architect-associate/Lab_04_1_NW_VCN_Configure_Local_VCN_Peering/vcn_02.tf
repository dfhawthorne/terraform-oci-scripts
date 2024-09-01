# ------------------------------------------------------------------------------
# OCI CAA Lab 04-1:
# Configure Local Virtual Cloud Network (VCN) Peering 
# Create VCN 02
# ------------------------------------------------------------------------------

# Virtual Cloud Network resource block
resource "oci_core_vcn" "FRA-AA-LAB04-1-VCN-02" {
    compartment_id  = var.compartment_id
    display_name    = "FRA-AA-LAB04-1-VCN-02"
    cidr_blocks     = ["192.168.0.0/16"]
    dns_label       = "fraaalab04vcn02"
}

resource "oci_core_nat_gateway" "NAT-gateway-FRA-AA-LAB04-1-VCN-02" {
  block_traffic     = "false"
  compartment_id    = var.compartment_id
  display_name      = "NAT gateway-FRA-AA-LAB04-1-VCN-02"
  vcn_id            = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.id
}

resource "oci_core_internet_gateway" "Internet-gateway-FRA-AA-LAB04-1-VCN-02" {
  compartment_id    = var.compartment_id
  display_name      = "Internet gateway-FRA-AA-LAB04-1-VCN-02"
  enabled           = "true"
  vcn_id            = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.id
}

resource "oci_core_local_peering_gateway" "FRA-AA-LAB04-1-LPG-02" {
    compartment_id  = var.compartment_id
    vcn_id          = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.id
    display_name    = "Local Peering Gateway-FRA-AA-LAB04-1-VCN-02"
}

resource "oci_core_default_dhcp_options" "DHCP-Options-for-FRA-AA-LAB04-1-VCN-02" {
  manage_default_resource_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.default_dhcp_options_id
  compartment_id    = var.compartment_id
  display_name      = "DHCP Options for FRA-AA-LAB04-1-VCN-02"
  domain_name_type  = "CUSTOM_DOMAIN"
  options {
    custom_dns_servers  = [
    ]
    server_type         = "VcnLocalPlusInternet"
    type                = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "fraaalab04vcn02.oraclevcn.com",
    ]
    type = "SearchDomain"
  }
}

resource "oci_core_subnet" "public-subnet-FRA-AA-LAB04-1-VCN-02" {
  cidr_block     = "192.168.0.0/24"
  compartment_id = var.compartment_id
  display_name    = "public subnet-FRA-AA-LAB04-1-VCN-02"
  dns_label       = "sub07051559030"
  ipv6cidr_blocks = [
  ]
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  security_list_ids = [
    oci_core_vcn.FRA-AA-LAB04-1-VCN-02.default_security_list_id,
  ]
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.id
}

resource oci_core_subnet private-subnet-FRA-AA-LAB04-1-VCN-02 {
  cidr_block     = "192.168.1.0/24"
  compartment_id = var.compartment_id
  display_name    = "private subnet-FRA-AA-LAB04-1-VCN-02"
  dns_label       = "sub07051559031"
  ipv6cidr_blocks = [
  ]
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.route-table-for-private-subnet-FRA-AA-LAB04-1-VCN-02.id
  security_list_ids = [
    oci_core_security_list.security-list-for-private-subnet-FRA-AA-LAB04-1-VCN-02.id,
  ]
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.id
}

resource oci_core_route_table route-table-for-private-subnet-FRA-AA-LAB04-1-VCN-02 {
  compartment_id = var.compartment_id
  display_name = "route table for private subnet-FRA-AA-LAB04-1-VCN-02"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.NAT-gateway-FRA-AA-LAB04-1-VCN-02.id
  }
  route_rules {
    destination       = "all-fra-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.Service-gateway-FRA-AA-LAB04-1-VCN-02.id
  }
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.id
}

resource oci_core_default_route_table default-route-table-for-FRA-AA-LAB04-1-VCN-02 {
  compartment_id              = var.compartment_id
  manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.default_route_table_id
  display_name                = "Default Route Table for FRA-AA-LAB04-1-VCN-02"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.Internet-gateway-FRA-AA-LAB04-1-VCN-02.id
  }
  route_rules {
    destination         = "172.16.0.0/24"
    destination_type    = "CIDR_BLOCK"
    network_entity_id   = oci_core_local_peering_gateway.FRA-AA-LAB04-1-LPG-02.id
  }
}


resource oci_core_security_list security-list-for-private-subnet-FRA-AA-LAB04-1-VCN-02 {
  compartment_id = var.compartment_id
  display_name = "security list for private subnet-FRA-AA-LAB04-1-VCN-02"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "192.168.0.0/16"
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
    source      = "192.168.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.id
}

resource oci_core_default_security_list Default-Security-List-for-FRA-AA-LAB04-1-VCN-02 {
  compartment_id = var.compartment_id
  display_name = "Default Security List for FRA-AA-LAB04-1-VCN-02"
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
    source      = "192.168.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "8"
    }
    protocol    = "1"
    source      = "172.16.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  manage_default_resource_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.default_security_list_id
}

resource oci_core_service_gateway Service-gateway-FRA-AA-LAB04-1-VCN-02 {
  compartment_id = var.compartment_id
  display_name = "Service gateway-FRA-AA-LAB04-1-VCN-02"
  services {
    service_id = "ocid1.service.oc1.eu-frankfurt-1.aaaaaaaalblrg4eycfxwohulzwwq63btwptzs2hva3muxfan5ro5x7glehtq"
  }
  vcn_id = oci_core_vcn.FRA-AA-LAB04-1-VCN-02.id
}

