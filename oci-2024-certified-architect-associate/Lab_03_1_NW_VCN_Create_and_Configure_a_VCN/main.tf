# ------------------------------------------------------------------------------
# OCI CAA Lab 3-1: 
# Networking - Virtual Cloud Network: Create and Configure a Virtual Cloud
# Network (VCN)
# ------------------------------------------------------------------------------

terraform {
    required_providers {
        oci = {
            source = "oracle/oci"
        }
    }
}

# ------------------------------------------------------------------------------
# Configure the Oracle Cloud Infrastructure provider with an API Key
# ------------------------------------------------------------------------------

provider "oci" {
  tenancy_ocid     = var.provider_details.tenancy_ocid
  user_ocid        = var.provider_details.user_ocid
  fingerprint      = var.provider_details.fingerprint
  private_key_path = var.provider_details.private_key_path
  region           = var.provider_details.region
}

# Virtual Cloud Network resource block
resource "oci_core_vcn" "FRA-AA-LAB03-VCN-01" {
    compartment_id  = var.compartment_id
    display_name    = "FRA-AA-LAB03-VCN-01"
    cidr_blocks     = ["10.0.0.0/16"]
    dns_label       = "fraaalab03vcn01"
}

resource "oci_core_nat_gateway" "NAT-gateway-FRA-AA-LAB03-VCN-01" {
  block_traffic     = "false"
  compartment_id    = var.compartment_id
  display_name      = "NAT gateway-FRA-AA-LAB03-VCN-01"
  vcn_id            = oci_core_vcn.FRA-AA-LAB03-VCN-01.id
}

resource "oci_core_internet_gateway" "Internet-gateway-FRA-AA-LAB03-VCN-01" {
  compartment_id    = var.compartment_id
  display_name      = "Internet gateway-FRA-AA-LAB03-VCN-01"
  enabled           = "true"
  vcn_id            = oci_core_vcn.FRA-AA-LAB03-VCN-01.id
}

resource "oci_core_default_dhcp_options" "DHCP-Options-for-FRA-AA-LAB03-VCN-01" {
  manage_default_resource_id = oci_core_vcn.FRA-AA-LAB03-VCN-01.default_dhcp_options_id
  compartment_id    = var.compartment_id
  display_name      = "DHCP Options for FRA-AA-LAB03-VCN-01"
  domain_name_type  = "CUSTOM_DOMAIN"
  options {
    custom_dns_servers  = [
    ]
    server_type         = "VcnLocalPlusInternet"
    type                = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "fraaalab03vcn01.oraclevcn.com",
    ]
    type = "SearchDomain"
  }
}

resource "oci_core_subnet" "public-subnet-FRA-AA-LAB03-VCN-01" {
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.compartment_id
  display_name    = "public subnet-FRA-AA-LAB03-VCN-01"
  dns_label       = "sub07051559030"
  ipv6cidr_blocks = [
  ]
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  security_list_ids = [
    oci_core_vcn.FRA-AA-LAB03-VCN-01.default_security_list_id,
  ]
  vcn_id = oci_core_vcn.FRA-AA-LAB03-VCN-01.id
}

resource oci_core_subnet private-subnet-FRA-AA-LAB03-VCN-01 {
  cidr_block     = "10.0.1.0/24"
  compartment_id = var.compartment_id
  display_name    = "private subnet-FRA-AA-LAB03-VCN-01"
  dns_label       = "sub07051559031"
  ipv6cidr_blocks = [
  ]
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.route-table-for-private-subnet-FRA-AA-LAB03-VCN-01.id
  security_list_ids = [
    oci_core_security_list.security-list-for-private-subnet-FRA-AA-LAB03-VCN-01.id,
  ]
  vcn_id = oci_core_vcn.FRA-AA-LAB03-VCN-01.id
}

resource oci_core_route_table route-table-for-private-subnet-FRA-AA-LAB03-VCN-01 {
  compartment_id = var.compartment_id
  display_name = "route table for private subnet-FRA-AA-LAB03-VCN-01"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.NAT-gateway-FRA-AA-LAB03-VCN-01.id
  }
  route_rules {
    destination       = "all-fra-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.Service-gateway-FRA-AA-LAB03-VCN-01.id
  }
  vcn_id = oci_core_vcn.FRA-AA-LAB03-VCN-01.id
}

resource oci_core_default_route_table default-route-table-for-FRA-AA-LAB03-VCN-01 {
  compartment_id              = var.compartment_id
  manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB03-VCN-01.default_route_table_id
  display_name                = "Default Route Table for FRA-AA-LAB03-VCN-01"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.Internet-gateway-FRA-AA-LAB03-VCN-01.id
  }
}


resource oci_core_security_list security-list-for-private-subnet-FRA-AA-LAB03-VCN-01 {
  compartment_id = var.compartment_id
  display_name = "security list for private subnet-FRA-AA-LAB03-VCN-01"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.0.0/16"
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
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.FRA-AA-LAB03-VCN-01.id
}

resource oci_core_default_security_list Default-Security-List-for-FRA-AA-LAB03-VCN-01 {
  compartment_id = var.compartment_id
  display_name = "Default Security List for FRA-AA-LAB03-VCN-01"
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
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  manage_default_resource_id = oci_core_vcn.FRA-AA-LAB03-VCN-01.default_security_list_id
}

resource oci_core_service_gateway Service-gateway-FRA-AA-LAB03-VCN-01 {
  compartment_id = var.compartment_id
  display_name = "Service gateway-FRA-AA-LAB03-VCN-01"
  services {
    service_id = "ocid1.service.oc1.eu-frankfurt-1.aaaaaaaalblrg4eycfxwohulzwwq63btwptzs2hva3muxfan5ro5x7glehtq"
  }
  vcn_id = oci_core_vcn.FRA-AA-LAB03-VCN-01.id
}

