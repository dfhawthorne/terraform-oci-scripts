# ------------------------------------------------------------------------------
# Lab 07-1: Compute: Create a Web Server on a Compute Instance
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#  Get Availability Domains and Compute Images
# ------------------------------------------------------------------------------

data "oci_identity_availability_domains" "ads" {
    compartment_id              = var.provider_details.tenancy_ocid
}

data "oci_core_images" "ol8_images" {
    compartment_id              = var.compartment_id
    operating_system            = "Oracle Linux"
    operating_system_version    = "8"
    shape                       = var.compute_shape
    sort_by                     = "TIMECREATED"
    sort_order                  = "DESC"
}

locals {
    ad1                         = data.oci_identity_availability_domains.ads.availability_domains[0].name
    latest_ol8_image            = data.oci_core_images.ol8_images.images[0].id
}

# ------------------------------------------------------------------------------
# Generate SSH Key Pair 
# ------------------------------------------------------------------------------

resource "tls_private_key" "ociaalab7key" {
    algorithm                   = "RSA"
    rsa_bits                    = 2048
}

output "private_key_pem" {
    value                       = tls_private_key.ociaalab7key.private_key_pem
    sensitive                   = true
}

# ------------------------------------------------------------------------------
# Create Virtual Cloud Network and associated resources
# ------------------------------------------------------------------------------

resource "oci_core_vcn" "FRA-AA-LAB07-VCN-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB07-VCN-01"
    cidr_blocks                 = ["10.0.0.0/16"]
    dns_label                   = "fraaalab07vcn01"
}

resource "oci_core_internet_gateway" "FRA-AA-LAB07-IG-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB07-IG-01"
    enabled                     = "true"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB07-VCN-01.id
}

resource "oci_core_default_dhcp_options" "DHCP-Options-for-FRA-AA-LAB07-VCN-01" {
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB07-VCN-01.default_dhcp_options_id
    compartment_id              = var.compartment_id
    display_name                = "DHCP Options for FRA-AA-LAB07-VCN-01"
    domain_name_type            = "CUSTOM_DOMAIN"
    options {
        custom_dns_servers      = [
        ]
        server_type             = "VcnLocalPlusInternet"
        type                    = "DomainNameServer"
    }
    options {
        search_domain_names     = [
        "fraaalab07vcn01.oraclevcn.com",
        ]
        type                    = "SearchDomain"
    }
}

resource "oci_core_subnet" "FRA-AA-LAB07-SNET-01" {
    cidr_block                  = "10.0.1.0/24"
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB07-SNET-01"
    dns_label                   = "public"
    ipv6cidr_blocks             = []
    prohibit_internet_ingress   = "false"
    prohibit_public_ip_on_vnic  = "false"
    security_list_ids           = [
        oci_core_vcn.FRA-AA-LAB07-VCN-01.default_security_list_id,
    ]
    vcn_id                      = oci_core_vcn.FRA-AA-LAB07-VCN-01.id
}

resource oci_core_default_route_table default-route-table-for-FRA-AA-LAB07-VCN-01 {
    compartment_id              = var.compartment_id
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB07-VCN-01.default_route_table_id
    display_name                = "Default Route Table for FRA-AA-LAB07-VCN-01"
    route_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        network_entity_id       = oci_core_internet_gateway.FRA-AA-LAB07-IG-01.id
    }
}

resource oci_core_default_security_list Default-Security-List-for-FRA-AA-LAB07-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "Default Security List for FRA-AA-LAB07-VCN-01"
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
        source                  = "10.0.0.0/16"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
    }
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB07-VCN-01.default_security_list_id
}

# ------------------------------------------------------------------------------
# Create a Compute Instance
# ------------------------------------------------------------------------------

resource "oci_core_instance" "FRA-AA-LAB07-VM-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB07-VM-01"
    availability_domain         = local.ad1
    shape                       = var.compute_shape
    shape_config                {
        ocpus                   = 1
        memory_in_gbs           = 6
    }
    source_details              {
        source_type             = "image"
        source_id               = local.latest_ol8_image
    }
    create_vnic_details         {
        subnet_id               = oci_core_subnet.FRA-AA-LAB07-SNET-01.id
        assign_public_ip        = true
        assign_ipv6ip           = false
    }
    metadata = {
        ssh_authorized_keys = tls_private_key.ociaalab7key.public_key_openssh
    }
}


output "vm_01_ip" {
    value                       = oci_core_instance.FRA-AA-LAB07-VM-01.public_ip
}

