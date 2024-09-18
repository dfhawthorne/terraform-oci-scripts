# ------------------------------------------------------------------------------
# OCI CAA Lab 6-1: 
# Networking - DNS Management: Create a private DNS Zone
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Get Data for Services, Availability Domains, and OL8 Images
# ------------------------------------------------------------------------------

data "oci_core_services" "frankfurt" {
}

data "oci_identity_availability_domains" "ads" {
    compartment_id              = var.provider_details.tenancy_ocid
}

data "oci_core_images" "linux_image" {
    compartment_id              = var.compartment_id
    operating_system            = "Oracle Linux"
    operating_system_version    = "8"
    shape                       = var.compute_shape
    sort_by                     = "TIMECREATED"
    sort_order                  = "DESC"
}

data "oci_core_images" "windows_image" {
    compartment_id              = var.compartment_id
    operating_system            = "Windows"
    shape                       = "VM.Standard.E4.Flex"
    sort_by                     = "TIMECREATED"
    sort_order                  = "DESC"

    filter {
        name                    = "display_name"
        values                  = ["^Windows-Server-2022-Standard-"]
        regex                   = true
    }
}


locals {
    ad1                         = data.oci_identity_availability_domains.ads.availability_domains[0].name
    ad2                         = data.oci_identity_availability_domains.ads.availability_domains[1].name
    ol8_image_ocid              = data.oci_core_images.linux_image.images[0].id
    win2022_image_ocid          = data.oci_core_images.windows_image.images[0].id
}

# ------------------------------------------------------------------------------
# Virtual Cloud Network resource block
# ------------------------------------------------------------------------------

resource "oci_core_vcn" "FRA-AA-LAB06-VCN-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB06-VCN-01"
    cidr_blocks                 = ["172.17.0.0/16"]
    dns_label                   = "fraaalab05vcn01"
}

# ------------------------------------------------------------------------------
# Gateways
# ------------------------------------------------------------------------------

resource "oci_core_nat_gateway" "NAT-gateway-FRA-AA-LAB06-VCN-01" {
  block_traffic                 = "false"
  compartment_id                = var.compartment_id
  display_name                  = "NAT gateway-FRA-AA-LAB06-VCN-01"
  vcn_id                        = oci_core_vcn.FRA-AA-LAB06-VCN-01.id
}

resource "oci_core_internet_gateway" "Internet-gateway-FRA-AA-LAB06-VCN-01" {
    compartment_id              = var.compartment_id
    display_name                = "Internet gateway-FRA-AA-LAB06-VCN-01"
    enabled                     = "true"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB06-VCN-01.id
}

resource oci_core_service_gateway Service-gateway-FRA-AA-LAB06-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "Service gateway-FRA-AA-LAB06-VCN-01"
    services {
        service_id              = data.oci_core_services.frankfurt.services[0].id
    }
    vcn_id                      = oci_core_vcn.FRA-AA-LAB06-VCN-01.id
}

# ------------------------------------------------------------------------------
# DHCP Options
# ------------------------------------------------------------------------------

resource "oci_core_default_dhcp_options" "DHCP-Options-for-FRA-AA-LAB06-VCN-01" {
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB06-VCN-01.default_dhcp_options_id
    compartment_id              = var.compartment_id
    display_name                = "Default DHCP Options for FRA-AA-LAB06-VCN-01"
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

resource "oci_core_subnet" "public-subnet-FRA-AA-LAB06-VCN-01" {
    cidr_block                  = "172.17.0.0/24"
    compartment_id              = var.compartment_id
    display_name                = "public subnet-FRA-AA-LAB06-VCN-01"
    dns_label                   = "public"
    ipv6cidr_blocks             = [
    ]
    prohibit_internet_ingress   = "false"
    prohibit_public_ip_on_vnic  = "false"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB06-VCN-01.id
}

resource oci_core_subnet private-subnet-FRA-AA-LAB06-VCN-01 {
    cidr_block                  = "172.17.1.0/24"
    compartment_id              = var.compartment_id
    display_name                = "private subnet-FRA-AA-LAB06-VCN-01"
    dns_label                   = "private"
    ipv6cidr_blocks             = [
    ]
    prohibit_internet_ingress   = "true"
    prohibit_public_ip_on_vnic  = "true"
    route_table_id              = oci_core_route_table.route-table-for-private-subnet-FRA-AA-LAB06-VCN-01.id
    security_list_ids           = [
        oci_core_security_list.security-list-for-private-subnet-FRA-AA-LAB06-VCN-01.id,
    ]
    vcn_id                      = oci_core_vcn.FRA-AA-LAB06-VCN-01.id
}

# ------------------------------------------------------------------------------
# Route Tables
# ------------------------------------------------------------------------------

resource oci_core_route_table route-table-for-private-subnet-FRA-AA-LAB06-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "route table for private subnet-FRA-AA-LAB06-VCN-01"
    route_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        network_entity_id       = oci_core_nat_gateway.NAT-gateway-FRA-AA-LAB06-VCN-01.id
    }
    route_rules {
        destination             = data.oci_core_services.frankfurt.services[0].cidr_block
        destination_type        = "SERVICE_CIDR_BLOCK"
        network_entity_id       = oci_core_service_gateway.Service-gateway-FRA-AA-LAB06-VCN-01.id
    }
    vcn_id                      = oci_core_vcn.FRA-AA-LAB06-VCN-01.id
}

resource oci_core_default_route_table default-route-table-for-FRA-AA-LAB06-VCN-01 {
    compartment_id              = var.compartment_id
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB06-VCN-01.default_route_table_id
    display_name                = "default route table for FRA-AA-LAB06-VCN-01"
    route_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        network_entity_id       = oci_core_internet_gateway.Internet-gateway-FRA-AA-LAB06-VCN-01.id
    }
}

# ------------------------------------------------------------------------------
# Security Lists (aka Firewall Rules)
# ------------------------------------------------------------------------------

resource oci_core_security_list security-list-for-private-subnet-FRA-AA-LAB06-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "security list for private subnet-FRA-AA-LAB06-VCN-01"
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
        source                  = "172.16.0.0/12"
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
    vcn_id                      = oci_core_vcn.FRA-AA-LAB06-VCN-01.id
}

resource oci_core_default_security_list Default-Security-List-for-FRA-AA-LAB06-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "Default Security List for FRA-AA-LAB06-VCN-01"
    egress_security_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        protocol                = "all"
        stateless               = "false"
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
        protocol                = "6"
        source                  = "0.0.0.0/0"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "3389"
            min                 = "3389"
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
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB06-VCN-01.default_security_list_id
}

# ------------------------------------------------------------------------------
# Create simple VM in the first availability domain
# ------------------------------------------------------------------------------

resource "oci_core_instance" "vm_01" {
    compartment_id              = var.compartment_id
    availability_domain         = local.ad1
    display_name                = "FRA-AA-LAB05-VM-01"
    shape                       = var.compute_shape
    shape_config                {
        ocpus                   = 1
        memory_in_gbs           = 6
    }
    source_details              {
        source_type             = "image"
        source_id               = local.ol8_image_ocid
    }
    create_vnic_details         {
        subnet_id               = oci_core_subnet.private-subnet-FRA-AA-LAB06-VCN-01.id
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
    availability_domain         = local.ad2
    display_name                = "FRA-AA-LAB05-VM-02"
    shape                       = "VM.Standard.E4.Flex"
    shape_config                {
        ocpus                   = 1
        memory_in_gbs           = 8
    }
    source_details              {
        source_type             = "image"
        source_id               = local.win2022_image_ocid
    }
    create_vnic_details         {
        subnet_id               = oci_core_subnet.public-subnet-FRA-AA-LAB06-VCN-01.id
        assign_public_ip        = true
        assign_ipv6ip           = false
    }
}

# ------------------------------------------------------------------------------
# Create a Private DNS Zone
# ------------------------------------------------------------------------------

resource "oci_dns_zone" "FRA-AA-LAB06-PZ-01" {
    compartment_id              = var.compartment_id
    name                        = "FRA-AA-LAB06-PrivateZone-01.com"
    zone_type                   = "PRIMARY"
    scope                       = "PRIVATE"
    view_id                     = oci_dns_view.FRA-AA-LAB06-DV-01.id
}

resource "oci_dns_view" "FRA-AA-LAB06-DV-01" {
    compartment_id              = var.compartment_id
    scope                       = "PRIVATE"
    display_name                = "FRA-AA-LAB06-DV-01"
}

resource "oci_dns_resolver" "dns_resolver" {
    attached_views {
        view_id                 = oci_dns_view.FRA-AA-LAB06-DV-01.id
    }
    display_name                = "my-dns-resolver"
    resolver_id                 = data.oci_core_vcn_dns_resolver_association.vcn_dns_resolver.dns_resolver_id
    scope                       = "PRIVATE"
}

data "oci_core_vcn_dns_resolver_association" "vcn_dns_resolver" {
    vcn_id                      = oci_core_vcn.FRA-AA-LAB06-VCN-01.id
}

resource "oci_dns_rrset" "test_rrset" {
    zone_name_or_id             = oci_dns_zone.FRA-AA-LAB06-PZ-01.id
    rtype                       = "A"
    domain                      = oci_dns_zone.FRA-AA-LAB06-PZ-01.name
	compartment_id              = var.compartment_id
	items {
		domain                  = oci_dns_zone.FRA-AA-LAB06-PZ-01.name
        rdata                   = oci_core_instance.vm_01.private_ip
        ttl                     = 30
		rtype                   = "A"
	}
	view_id                     = oci_dns_view.FRA-AA-LAB06-DV-01.id
}

