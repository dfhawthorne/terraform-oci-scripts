# ------------------------------------------------------------------------------
# OCI CAA Lab 5-1: 
# Networking - OCI Load Balancer
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Get Data for Services, Availability Domains, and OL8 Images
# ------------------------------------------------------------------------------

data "oci_core_services" "frankfurt" {
}

# ------------------------------------------------------------------------------
# Virtual Cloud Network resource block
# ------------------------------------------------------------------------------

resource "oci_core_vcn" "FRA-AA-LAB05-VCN-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB05-VCN-01"
    cidr_blocks                 = ["172.17.0.0/16"]
    dns_label                   = "fraaalab05vcn01"
}

# ------------------------------------------------------------------------------
# Gateways
# ------------------------------------------------------------------------------

resource "oci_core_nat_gateway" "NAT-gateway-FRA-AA-LAB05-VCN-01" {
  block_traffic                 = "false"
  compartment_id                = var.compartment_id
  display_name                  = "NAT gateway-FRA-AA-LAB05-VCN-01"
  vcn_id                        = oci_core_vcn.FRA-AA-LAB05-VCN-01.id
}

resource "oci_core_internet_gateway" "Internet-gateway-FRA-AA-LAB05-VCN-01" {
    compartment_id              = var.compartment_id
    display_name                = "Internet gateway-FRA-AA-LAB05-VCN-01"
    enabled                     = "true"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB05-VCN-01.id
}

resource oci_core_service_gateway Service-gateway-FRA-AA-LAB05-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "Service gateway-FRA-AA-LAB05-VCN-01"
    services {
        service_id              = data.oci_core_services.frankfurt.services[0].id
    }
    vcn_id                      = oci_core_vcn.FRA-AA-LAB05-VCN-01.id
}

# ------------------------------------------------------------------------------
# DHCP Options
# ------------------------------------------------------------------------------

resource "oci_core_default_dhcp_options" "DHCP-Options-for-FRA-AA-LAB05-VCN-01" {
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB05-VCN-01.default_dhcp_options_id
    compartment_id              = var.compartment_id
    display_name                = "DHCP Options for FRA-AA-LAB05-VCN-01"
    domain_name_type            = "CUSTOM_DOMAIN"
    options {
        custom_dns_servers      = [
        ]
        server_type             = "VcnLocalPlusInternet"
        type                    = "DomainNameServer"
    }
    options {
        search_domain_names     = [
            "fraaalab05vcn01.oraclevcn.com",
        ]
        type                    = "SearchDomain"
    }
}

# ------------------------------------------------------------------------------
# Subnets 
# ------------------------------------------------------------------------------

resource "oci_core_subnet" "public-subnet-FRA-AA-LAB05-VCN-01" {
    cidr_block                  = "172.17.0.0/24"
    compartment_id              = var.compartment_id
    display_name                = "public subnet-FRA-AA-LAB05-VCN-01"
    dns_label                   = "public"
    ipv6cidr_blocks             = [
    ]
    prohibit_internet_ingress   = "false"
    prohibit_public_ip_on_vnic  = "false"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB05-VCN-01.id
}

resource oci_core_subnet private-subnet-FRA-AA-LAB05-VCN-01 {
    cidr_block                  = "172.17.1.0/24"
    compartment_id              = var.compartment_id
    display_name                = "private subnet-FRA-AA-LAB05-VCN-01"
    dns_label                   = "private"
    ipv6cidr_blocks             = [
    ]
    prohibit_internet_ingress   = "true"
    prohibit_public_ip_on_vnic  = "true"
    route_table_id              = oci_core_route_table.route-table-for-private-subnet-FRA-AA-LAB05-VCN-01.id
    security_list_ids           = [
        oci_core_security_list.security-list-for-private-subnet-FRA-AA-LAB05-VCN-01.id,
    ]
    vcn_id                      = oci_core_vcn.FRA-AA-LAB05-VCN-01.id
}

# ------------------------------------------------------------------------------
# Route Tables
# ------------------------------------------------------------------------------

resource oci_core_route_table route-table-for-private-subnet-FRA-AA-LAB05-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "route table for private subnet-FRA-AA-LAB05-VCN-01"
    route_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        network_entity_id       = oci_core_nat_gateway.NAT-gateway-FRA-AA-LAB05-VCN-01.id
    }
    route_rules {
        destination             = data.oci_core_services.frankfurt.services[0].cidr_block
        destination_type        = "SERVICE_CIDR_BLOCK"
        network_entity_id       = oci_core_service_gateway.Service-gateway-FRA-AA-LAB05-VCN-01.id
    }
    vcn_id                      = oci_core_vcn.FRA-AA-LAB05-VCN-01.id
}

resource oci_core_default_route_table default-route-table-for-FRA-AA-LAB05-VCN-01 {
    compartment_id              = var.compartment_id
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB05-VCN-01.default_route_table_id
    display_name                = "Default Route Table for FRA-AA-LAB05-VCN-01"
    route_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        network_entity_id       = oci_core_internet_gateway.Internet-gateway-FRA-AA-LAB05-VCN-01.id
    }
}

# ------------------------------------------------------------------------------
# Security Lists (aka Firewall Rules)
# ------------------------------------------------------------------------------

resource oci_core_security_list security-list-for-private-subnet-FRA-AA-LAB05-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "security list for private subnet-FRA-AA-LAB05-VCN-01"
    egress_security_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        protocol                = "all"
        stateless               = "false"
    }
    ingress_security_rules {
        protocol                = "6"
        source                  = "172.17.0.0/16"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "22"
            min                 = "22"
        }
    }
    ingress_security_rules {
        protocol                = "6"
        source                  = "172.17.0.0/16"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "80"
            min                 = "80"
        }
    }
    ingress_security_rules {
        icmp_options {
            code                = "4"
            type                = "3"
        }
        protocol                = "1"
        source                  = "0.0.0.0/0"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
    }
    ingress_security_rules {
        icmp_options {
            code                = "-1"
            type                = "3"
        }
        protocol                = "1"
        source                  = "172.17.0.0/16"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
    }
    vcn_id                      = oci_core_vcn.FRA-AA-LAB05-VCN-01.id
}

resource oci_core_default_security_list Default-Security-List-for-FRA-AA-LAB05-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "Default Security List for FRA-AA-LAB05-VCN-01"
    egress_security_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        protocol                = "all"
        stateless               = "false"
    }
    egress_security_rules {
        destination             = "172.17.1.0/24"
        destination_type        = "CIDR_BLOCK"
        protocol                = "6"
        stateless               = false
        tcp_options {
            max                 = 80
            min                 = 80
        }
    }
    ingress_security_rules {
        protocol                = "6"
        source                  = "0.0.0.0/0"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "22"
            min                 = "22"
        }
    }
    ingress_security_rules {
        protocol                = "6"
        source                  = "0.0.0.0/0"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "80"
            min                 = "80"
        }
    }
    ingress_security_rules {
        icmp_options {
            code                = "4"
            type                = "3"
        }
        protocol                = "1"
        source                  = "0.0.0.0/0"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
    }
    ingress_security_rules {
        icmp_options {
            code                = "-1"
            type                = "3"
        }
        protocol                = "1"
        source                  = "172.17.0.0/16"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
    }
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB05-VCN-01.default_security_list_id
}

# ------------------------------------------------------------------------------
# Create simple VM in the first availability domain
# ------------------------------------------------------------------------------

resource "oci_core_instance" "vm_01" {
    compartment_id              = var.compartment_id
    availability_domain         = "misp:EU-FRANKFURT-1-AD-1"
    display_name                = "FRA-AA-LAB05-VM-01"
    shape                       = "VM.Standard.A1.Flex"
    shape_config                {
        ocpus                   = 1
        memory_in_gbs           = 6
    }
    source_details              {
        source_type             = "image"
        source_id               = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa2ebpx7hhgkhfarlopt3h6krrhxmw743gwuopg62euwufjelwgsxa"
    }
    create_vnic_details         {
        subnet_id               = oci_core_subnet.private-subnet-FRA-AA-LAB05-VCN-01.id
        assign_public_ip        = false
        assign_ipv6ip           = false
    }
    metadata                    = {
        user_data               = data.cloudinit_config.vm01_config.rendered
    }
}

data "cloudinit_config" "vm01_config" {
    gzip                        = true
    base64_encode               = true
    part                        {
        content_type            = "text/cloud-config"
        content                 = templatefile("configure_apache.tftpl", {
            server_name         = "FRA-AA-LAB05-VM-01"
        })
        filename                = "configure_apache.yaml"
    }
}

# ------------------------------------------------------------------------------
# Create simple VM in the second availability domain
# ------------------------------------------------------------------------------

resource "oci_core_instance" "vm_02" {
    compartment_id              = var.compartment_id
    availability_domain         = "misp:EU-FRANKFURT-1-AD-2"
    display_name                = "FRA-AA-LAB05-VM-02"
    shape                       = "VM.Standard.A1.Flex"
    shape_config                {
        ocpus                   = 1
        memory_in_gbs           = 6
    }
    source_details              {
        source_type             = "image"
        source_id               = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa2ebpx7hhgkhfarlopt3h6krrhxmw743gwuopg62euwufjelwgsxa"
    }
    create_vnic_details         {
        subnet_id               = oci_core_subnet.public-subnet-FRA-AA-LAB05-VCN-01.id
        assign_public_ip        = true
        assign_ipv6ip           = false
    }
    metadata                    = {
        user_data               = data.cloudinit_config.vm02_config.rendered
        ssh_authorized_keys     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCIy4S9IY6KWq21kMVOZzljJ1sZp8wtOF8tcHpC3sdvXUefQM3A2eZdwn+Yb1CDirqRNcdHU8SswjABF4pUUlvRTcTietPVyxV3fgiwbm8lS56DhH89hhfj+ymkFZdH6Mlw3Q+Q1dNqjmiwyuRBwPqQFvYqfXGfrTvZtxrSYE3YxLhfchRdJWzJEP1mOcCW81biTbHkH9u27R3o5GDHSpeFvhis7hNHDt0ayb77jkulLKHFVImoiph9pLkCBMfQgpCR+MkUxyyKB0KhKj7rLtZpaGUkbb+GCMhtNAdsv1YuvrDKx4/oyJtdYw5RQRZNVcW9e+4JTOob4HL/utPB9uPz17b8e/zqj+yzQz1Mf2NthPEG22os4BOqqi+7QuirhMEj1xzXePTpd6FWYZyJB4tk/J5KIwKtQhOSs+4MJz945+GFBD21YoqaYv9WUB6ZL7el+HwcqFyaPJUm6i4Nkdx3DHv9pjaF6DcRKzcKroCoEW57uwBZej3sNhEHBE+VI1M= mylearn@coogee"
    }
}

data "cloudinit_config" "vm02_config" {
    gzip                        = true
    base64_encode               = true
    part                        {
        content_type            = "text/cloud-config"
        content                 = templatefile("configure_apache.tftpl", {
            server_name         = "FRA-AA-LAB05-VM-02"
        })
        filename                = "configure_apache.yaml"
    }
}

# ------------------------------------------------------------------------------
# Load Balancer
# ------------------------------------------------------------------------------

resource "oci_load_balancer_load_balancer" "FRA-AA-LAB-5-LB-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB-5-LB-01"
    shape                       = "flexible"
    subnet_ids                  = [oci_core_subnet.public-subnet-FRA-AA-LAB05-VCN-01.id]
    is_private                  = false
    shape_details {
        maximum_bandwidth_in_mbps = 20
        minimum_bandwidth_in_mbps = 10
    }
}

resource "oci_load_balancer_backend_set" "FRA-AA-LAB-5-BS-01" {
    name                        = "FRA-AA-LAB-5-BS-01"
    load_balancer_id            = oci_load_balancer_load_balancer.FRA-AA-LAB-5-LB-01.id
    policy                      = "ROUND_ROBIN"
    health_checker              {
        port                    = "80"
        protocol                = "HTTP"
        response_body_regex     = ".*"
        url_path                = "/"
    }
}

resource "oci_load_balancer_backend" "FRA-AA-LAB-5-BE-01" {
    load_balancer_id            = oci_load_balancer_load_balancer.FRA-AA-LAB-5-LB-01.id
    backendset_name             = oci_load_balancer_backend_set.FRA-AA-LAB-5-BS-01.name
    ip_address                  = oci_core_instance.vm_01.private_ip
    port                        = "80"
}

resource "oci_load_balancer_backend" "FRA-AA-LAB-5-BE-02" {
    load_balancer_id            = oci_load_balancer_load_balancer.FRA-AA-LAB-5-LB-01.id
    backendset_name             = oci_load_balancer_backend_set.FRA-AA-LAB-5-BS-01.name
    ip_address                  = oci_core_instance.vm_02.private_ip
    port                        = "80"
}

resource "oci_load_balancer_listener" "FRA-AA-LAB-5-listener-01" {
    load_balancer_id            = oci_load_balancer_load_balancer.FRA-AA-LAB-5-LB-01.id
    name                        = "FRA-AA-LAB-5-listener-01"
    default_backend_set_name    = oci_load_balancer_backend_set.FRA-AA-LAB-5-BS-01.name
    port                        = 80
    protocol                    = "HTTP"
}

