# ------------------------------------------------------------------------------
# Lab 14-1: File Storage: Create and Mount a File System
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

resource "tls_private_key" "ociaalab14key" {
    algorithm                   = "RSA"
    rsa_bits                    = 2048
}

# ------------------------------------------------------------------------------
# Create Virtual Cloud Network and associated resources
# ------------------------------------------------------------------------------

resource "oci_core_vcn" "FRA-AA-LAB14-1-VCN-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB14-1-VCN-01"
    cidr_blocks                 = ["10.0.0.0/16"]
    dns_label                   = "fraaalab14vcn01"
}

resource "oci_core_internet_gateway" "FRA-AA-LAB14-1-IG-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB14-1-IG-01"
    enabled                     = "true"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB14-1-VCN-01.id
}

resource "oci_core_default_dhcp_options" "DHCP-Options-for-FRA-AA-LAB14-1-VCN-01" {
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB14-1-VCN-01.default_dhcp_options_id
    compartment_id              = var.compartment_id
    display_name                = "DHCP Options for FRA-AA-LAB14-1-VCN-01"
    domain_name_type            = "CUSTOM_DOMAIN"
    options {
        custom_dns_servers      = [
        ]
        server_type             = "VcnLocalPlusInternet"
        type                    = "DomainNameServer"
    }
    options {
        search_domain_names     = [
        "fraaalab14vcn01.oraclevcn.com",
        ]
        type                    = "SearchDomain"
    }
}

resource "oci_core_subnet" "FRA-AA-LAB14-1-SNET-01" {
    cidr_block                  = "10.0.1.0/24"
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB14-1-SNET-01"
    dns_label                   = "FRAAALAB141SNE1"
    ipv6cidr_blocks             = []
    prohibit_internet_ingress   = "false"
    prohibit_public_ip_on_vnic  = "false"
    security_list_ids           = [
        oci_core_vcn.FRA-AA-LAB14-1-VCN-01.default_security_list_id,
    ]
    vcn_id                      = oci_core_vcn.FRA-AA-LAB14-1-VCN-01.id
}

resource "oci_core_subnet" "FRA-AA-LAB14-1-SNET-02" {
    cidr_block                  = "10.0.2.0/24"
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB14-1-SNET-02"
    dns_label                   = "FRAAALAB141SNE2"
    ipv6cidr_blocks             = []
    prohibit_internet_ingress   = "false"
    prohibit_public_ip_on_vnic  = "false"
    security_list_ids           = [
        oci_core_security_list.FRA-AA-LAB14-1-SL-01.id,
    ]
    vcn_id                      = oci_core_vcn.FRA-AA-LAB14-1-VCN-01.id
}

resource oci_core_default_route_table default-route-table-for-FRA-AA-LAB14-1-VCN-01 {
    compartment_id              = var.compartment_id
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB14-1-VCN-01.default_route_table_id
    display_name                = "Default Route Table for FRA-AA-LAB14-1-VCN-01"
    route_rules {
        destination             = "0.0.0.0/0"
        destination_type        = "CIDR_BLOCK"
        network_entity_id       = oci_core_internet_gateway.FRA-AA-LAB14-1-IG-01.id
    }
}

resource oci_core_default_security_list Default-Security-List-for-FRA-AA-LAB14-1-VCN-01 {
    compartment_id              = var.compartment_id
    display_name                = "Default Security List for FRA-AA-LAB14-1-VCN-01"
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
    ingress_security_rules {
        protocol                = "6"
        source                  = "10.0.1.0/24"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            source_port_range {
                max             = "111"
                min             = "111"
            }
        }
    }
    ingress_security_rules {
        protocol                = "6"
        source                  = "10.0.1.0/24"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            source_port_range {
                max             = "2050"
                min             = "2048"
            }
        }
    }
    ingress_security_rules {
        protocol                = "17"
        source                  = "10.0.1.0/24"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        udp_options {
            source_port_range {
                max             = "111"
                min             = "111"
            }
        }
    }
    ingress_security_rules {
        protocol                = "17"
        source                  = "10.0.1.0/24"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        udp_options {
            source_port_range {
                max             = "2050"
                min             = "2048"
            }
        }
    }
    egress_security_rules {
        protocol                = "6"
        destination             = "10.0.2.0/24"
        destination_type        = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "111"
            min                 = "111"
        }
    }
    egress_security_rules {
        protocol                = "6"
        destination             = "10.0.2.0/24"
        destination_type        = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "2050"
            min                 = "2048"
        }
    }
    egress_security_rules {
        protocol                = "17"
        destination             = "10.0.2.0/24"
        destination_type        = "CIDR_BLOCK"
        stateless               = "false"
        udp_options {
            max                 = "111"
            min                 = "111"
        }
    }
    egress_security_rules {
        protocol                = "17"
        destination             = "10.0.2.0/24"
        destination_type        = "CIDR_BLOCK"
        stateless               = "false"
        udp_options {
            max                 = "2050"
            min                 = "2048"
        }
    }
    manage_default_resource_id  = oci_core_vcn.FRA-AA-LAB14-1-VCN-01.default_security_list_id
}

resource oci_core_security_list FRA-AA-LAB14-1-SL-01 {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB14-1-SL-01"
    vcn_id                      = oci_core_vcn.FRA-AA-LAB14-1-VCN-01.id
    ingress_security_rules {
        protocol                = "6"
        source                  = "10.0.1.0/24"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "111"
            min                 = "111"
        }
    }
    ingress_security_rules {
        protocol                = "6"
        source                  = "10.0.1.0/24"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "2050"
            min                 = "2048"
        }
    }
    ingress_security_rules {
        protocol                = "17"
        source                  = "10.0.1.0/24"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        udp_options {
            max                 = "111"
            min                 = "111"
        }
    }
    ingress_security_rules {
        protocol                = "17"
        source                  = "10.0.1.0/24"
        source_type             = "CIDR_BLOCK"
        stateless               = "false"
        udp_options {
            max                 = "2050"
            min                 = "2048"
        }
    }
    egress_security_rules {
        protocol                = "6"
        destination             = "10.0.2.0/24"
        destination_type        = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "111"
            min                 = "111"
        }
    }
    egress_security_rules {
        protocol                = "6"
        destination             = "10.0.2.0/24"
        destination_type        = "CIDR_BLOCK"
        stateless               = "false"
        tcp_options {
            max                 = "2050"
            min                 = "2048"
        }
    }
    egress_security_rules {
        protocol                = "17"
        destination             = "10.0.2.0/24"
        destination_type        = "CIDR_BLOCK"
        stateless               = "false"
        udp_options {
            max                 = "111"
            min                 = "111"
        }
    }
    egress_security_rules {
        protocol                = "17"
        destination             = "10.0.2.0/24"
        destination_type        = "CIDR_BLOCK"
        stateless               = "false"
        udp_options {
            max                 = "2050"
            min                 = "2048"
        }
    }
}

# ------------------------------------------------------------------------------
# Create Compute Instances
# ------------------------------------------------------------------------------

resource "oci_core_instance" "FRA-AA-LAB14-1-VM-01" {
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB14-1-VM-01"
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
        subnet_id               = oci_core_subnet.FRA-AA-LAB14-1-SNET-01.id
        assign_public_ip        = true
        assign_ipv6ip           = false
    }
    metadata = {
        ssh_authorized_keys = tls_private_key.ociaalab14key.public_key_openssh
    }
}

# ------------------------------------------------------------------------------
# Create a File System 
# ------------------------------------------------------------------------------

resource "oci_file_storage_file_system" "FRA-AA-LAB14-1-FS-01" {
    availability_domain         = local.ad1
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB14-1-FS-01"
}

resource "oci_file_storage_mount_target" "FRA-AA-LAB14-1-MNT-01" {
    availability_domain         = local.ad1
    compartment_id              = var.compartment_id
    subnet_id                   = oci_core_subnet.FRA-AA-LAB14-1-SNET-02.id
    display_name                = "FRA-AA-LAB14-1-MNT-01"
}

locals {
    vm_source_ip_01             = "${oci_core_instance.FRA-AA-LAB14-1-VM-01.private_ip}/32"
}

resource "oci_file_storage_export" "FRA-AA-LAB14-1-EP-01" {
    export_set_id               = oci_file_storage_export_set.FRA-AA-LAB14-1-ES-01.id
    file_system_id              = oci_file_storage_file_system.FRA-AA-LAB14-1-FS-01.id
    path                        = "/FRA-AA-LAB14-1-EP-01"
}

resource "oci_file_storage_export_set" "FRA-AA-LAB14-1-ES-01" {
    mount_target_id             = oci_file_storage_mount_target.FRA-AA-LAB14-1-MNT-01.id
    display_name                = "FRA-AA-LAB14-1-ES-01"
}
