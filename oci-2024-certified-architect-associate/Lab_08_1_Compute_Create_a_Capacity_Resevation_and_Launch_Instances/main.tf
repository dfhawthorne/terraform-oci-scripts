# ------------------------------------------------------------------------------
# Lab 8-1: Compute: Create a Capacity Reservation and Launch Instances
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Get Availability Domains, and OL8 Images
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
    latest_ol8_image_id         = data.oci_core_images.ol8_images.images[0].id
    latest_ol8_image_name       = data.oci_core_images.ol8_images.images[0].display_name
}

# ------------------------------------------------------------------------------
# Generate SSH Key Pair 
# ------------------------------------------------------------------------------

resource "tls_private_key" "ociaalab08key" {
    algorithm                   = "RSA"
    rsa_bits                    = 2048
}

# -----------------------------------------------------------------------------
# Create a Virtual Cloud Network and a subnet
# -----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Virtual Cloud Network resource block
# ------------------------------------------------------------------------------

resource "oci_core_vcn" "FRA-AA-LAB08-1-VCN-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB08-1-VCN-01"
    cidr_blocks                 = ["10.0.0.0/16"]
    dns_label                   = "fraaalab081vcn1"
}

# ------------------------------------------------------------------------------
# Attach Gateways to VCN
# ------------------------------------------------------------------------------

resource "oci_core_internet_gateway" "FRA-AA-LAB08-1-IG-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB08-1-IG-01"
    enabled                     = "true"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB08-1-VCN-01.id
}

# ------------------------------------------------------------------------------
# DHCP Options
# ------------------------------------------------------------------------------

resource "oci_core_default_dhcp_options" "DHCP-Options" {
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB08-1-VCN-01.default_dhcp_options_id
    compartment_id              = var.compartment_id
    display_name                = "DHCP Options for FRA-AA-LAB08-1-VCN-01"
    domain_name_type            = "CUSTOM_DOMAIN"
    options {
        custom_dns_servers      = [
        ]
        server_type             = "VcnLocalPlusInternet"
        type                    = "DomainNameServer"
    }
    options {
        search_domain_names     = [
            "fraaalab081vcn1.oraclevcn.com",
        ]
        type = "SearchDomain"
    }
}

# ------------------------------------------------------------------------------
# Subnets
# ------------------------------------------------------------------------------

resource "oci_core_subnet" "FRA-AA-LAB08-1-SNET-01" {
    cidr_block                  = "10.0.0.0/24"
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB08-1-SNET-01"
    dns_label                   = "public"
    prohibit_internet_ingress   = "false"
    prohibit_public_ip_on_vnic  = "false"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB08-1-VCN-01.id
}

# ------------------------------------------------------------------------------
# Route tables
# ------------------------------------------------------------------------------

resource "oci_core_default_route_table" "default-route-table" {
    compartment_id              = var.compartment_id
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB08-1-VCN-01.default_route_table_id
    display_name                = "default route table for FRA-AA-LAB08-1-VCN-01"
    route_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        network_entity_id       = oci_core_internet_gateway.FRA-AA-LAB08-1-IG-01.id
    }
}

# ------------------------------------------------------------------------------
# Security lists (aka Firewall Rules)
# ------------------------------------------------------------------------------

resource "oci_core_default_security_list" "Default-Security-List" {
    compartment_id              = var.compartment_id
    display_name                = "Default Security List for FRA-AA-LAB08-1-VCN-01"
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
        source                  = "10.0.0.0/16"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
    }
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB08-1-VCN-01.default_security_list_id
}


# -----------------------------------------------------------------------------
# Create a capacity reservation
# Add a capacity configuration
# -----------------------------------------------------------------------------

resource "oci_core_compute_capacity_reservation" "FRA-AA-LAB08-1-RESV-01" {
    compartment_id                  = var.compartment_id
    availability_domain             = local.ad1
    display_name                    = "FRA-AA-LAB08-1-RESV-01"

    instance_reservation_configs {
        instance_shape              = var.compute_shape
        reserved_count              = 1
        
        instance_shape_config {
            ocpus                   = 1
            memory_in_gbs           = 6
        }
    }

#    instance_reservation_configs {
#        instance_shape              = "VM.Standard.E4.Flex"
#        reserved_count              = 1
#        
#        instance_shape_config {
#            ocpus                   = 1
#            memory_in_gbs           = 8
#        }
#    }

    is_default_reservation          = false
}

# -----------------------------------------------------------------------------
# Create instances in a capacity reservation
# -----------------------------------------------------------------------------

resource "oci_core_instance" "FRA-AA-LAB08-1-VM-01" {
    availability_domain             = local.ad1
    compartment_id                  = var.compartment_id
    shape                           = var.compute_shape

    create_vnic_details {
        subnet_id                   = module.vcn_01.pub_snet_id
        assign_public_ip            = true
    }

    source_details {
        source_type                 = "image"
        source_id                   = local.latest_ol8_image_id
    }

    capacity_reservation_id = oci_core_compute_capacity_reservation.FRA-AA-LAB08-1-RESV-01.id

    shape_config                {
        ocpus                       = 1
        memory_in_gbs               = 6
    }

    metadata = {
        ssh_authorized_keys         = tls_private_key.ociaalab08key.public_key_openssh
    }
}