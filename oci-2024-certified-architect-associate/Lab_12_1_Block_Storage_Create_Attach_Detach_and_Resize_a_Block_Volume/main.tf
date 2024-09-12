# ------------------------------------------------------------------------------
# Lab 12-1:
#   Object Storage:
#     Create and Manage OCI Object Storage
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Get Data for Services, Availability Domains, and OL8 Images
# ------------------------------------------------------------------------------

data "oci_core_services" "frankfurt" {
}

data "oci_identity_availability_domains" "ads" {
    compartment_id              = var.provider_details.tenancy_ocid
}

data "oci_core_images" "latest_image" {
    compartment_id              = var.compartment_id
    operating_system            = "Oracle Linux"
    operating_system_version    = "8"
    shape                       = var.compute_shape
    sort_by                     = "TIMECREATED"
    sort_order                  = "DESC"
}


locals {
    ad1                         = data.oci_identity_availability_domains.ads.availability_domains[0].name
    ad2                         = data.oci_identity_availability_domains.ads.availability_domains[1].name
    ol8_image_ocid              = data.oci_core_images.latest_image.images[0].id
}

# ------------------------------------------------------------------------------
# Virtual Cloud Network resource block
# ------------------------------------------------------------------------------

resource "oci_core_vcn" "FRA-AA-LAB12-1-VCN-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB12-1-VCN-01"
    cidr_blocks                 = ["10.0.0.0/16"]
    dns_label                   = "fraaalab12vcn01"
}

# ------------------------------------------------------------------------------
# Gateways
# ------------------------------------------------------------------------------

resource "oci_core_internet_gateway" "Internet-gateway-FRA-AA-LAB12-1-VCN-01" {
    compartment_id              = var.compartment_id
    display_name                = "Internet gateway-FRA-AA-LAB12-1-VCN-01"
    enabled                     = "true"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB12-1-VCN-01.id
}

# ------------------------------------------------------------------------------
# DHCP Options
# ------------------------------------------------------------------------------

resource "oci_core_default_dhcp_options" "DHCP-Options-for-FRA-AA-LAB12-1-VCN-01" {
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB12-1-VCN-01.default_dhcp_options_id
    compartment_id              = var.compartment_id
    display_name                = "Default DHCP Options for FRA-AA-LAB12-1-VCN-01"
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

resource "oci_core_subnet" "FRA-AA-LAB12-1-SNET-01" {
    cidr_block                  = "10.0.1.0/24"
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB12-1-SNET-01"
    dns_label                   = "public"
    ipv6cidr_blocks             = [
    ]
    prohibit_internet_ingress   = "false"
    prohibit_public_ip_on_vnic  = "false"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB12-1-VCN-01.id
}

# ------------------------------------------------------------------------------
# Route Tables
# ------------------------------------------------------------------------------

resource oci_core_default_route_table default-route-table-for-FRA-AA-LAB12-1-VCN-01 {
    compartment_id              = var.compartment_id
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB12-1-VCN-01.default_route_table_id
    display_name                = "default route table for FRA-AA-LAB12-1-VCN-01"
    route_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        network_entity_id       = oci_core_internet_gateway.Internet-gateway-FRA-AA-LAB12-1-VCN-01.id
    }
}

# ------------------------------------------------------------------------------
# Security Lists (aka Firewall Rules)
# ------------------------------------------------------------------------------

resource oci_core_default_security_list Default-Security-List-for-FRA-AA-LAB12-1-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "Default Security List for FRA-AA-LAB12-1-VCN-01"
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
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB12-1-VCN-01.default_security_list_id
}

# ------------------------------------------------------------------------------
# Create simple VM in the first availability domain
# ------------------------------------------------------------------------------

resource "oci_core_instance" "vm_01" {
    compartment_id              = var.compartment_id
    availability_domain         = local.ad1
    display_name                = "FRA-AA-LAB12-1-VM-01"
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
        subnet_id               = oci_core_subnet.FRA-AA-LAB12-1-SNET-01.id
        assign_public_ip        = true
        assign_ipv6ip           = false
    }
    metadata                    = {
        ssh_authorized_keys     = var.ssh_public_key
    }
}

# ------------------------------------------------------------------------------
# Create and attach a block volume
# ------------------------------------------------------------------------------

resource "oci_core_volume" "FRA-AA-LAB12-1-BV-01" {
    availability_domain         = local.ad1
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB12-1-BV-01"
    size_in_gbs                 = 1024
    vpus_per_gb                 = 0
}

resource "oci_core_volume_attachment" "FRA-AA-LAB12-1-VA-01" {
    attachment_type             = "paravirtualized"
    instance_id                 = oci_core_instance.vm_01.id
    volume_id                   = oci_core_volume.FRA-AA-LAB12-1-BV-01.id
    device                      = "/dev/oracleoci/oraclevdb"
}
