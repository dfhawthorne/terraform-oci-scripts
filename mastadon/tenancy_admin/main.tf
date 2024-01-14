# ------------------------------------------------------------------------------
# Terraform script for Mastadon Server Farm
# ------------------------------------------------------------------------------

# Warning: Additional provider information from registry
#
# The remote registry returned warnings for registry.terraform.io/hashicorp/oci:
# - For users on Terraform 0.13 or greater, this provider has moved to oracle/oci. Please update your
# source in required_providers.

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
    }
  }
}

# Configure the Oracle Cloud Infrastructure provider with an API Key
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# ------------------------------------------------------------------------------
# Security Configuration
# ------------------------------------------------------------------------------

# Create Mastadon Compartment
resource "oci_identity_compartment" "mastadon_compartment" {
    compartment_id = var.tenancy_ocid
    description    = var.mastadon_compartment_description
    name           = var.mastadon_compartment_name
}

# Create Mastadon IAM Domain
resource "oci_identity_domain" "mastadon_domain" {
    compartment_id = oci_identity_compartment.mastadon_compartment.id
    description    = var.mastadon_domain_description
    display_name   = var.mastadon_domain_display_name
    home_region    = var.region
    license_type   = var.domain_license_type
}

# ------------------------------------------------------------------------------
# Mastadon Network
# ------------------------------------------------------------------------------

resource "oci_core_vcn" "mastadon_vcn" {
    compartment_id = oci_identity_compartment.mastadon_compartment.id
    cidr_block     = "10.1.0.0/16"
    display_name   = "Mastadon_Network"
    dns_label      = "mastadon"
}

# Create Mastadon Web Server Sub-Network
resource "oci_core_subnet" "mastadon_web_subnet" {
    cidr_block     = "10.1.0.0/24"
    compartment_id = oci_identity_compartment.mastadon_compartment.id
    vcn_id         = oci_core_vcn.mastadon_vcn.id
    display_name   = "Mastadon Web Server Sub-Network"
}

# Create Mastadon DB Server Network
resource "oci_core_subnet" "mastadon_db_subnet" {
    cidr_block     = "10.1.1.0/24"
    compartment_id = oci_identity_compartment.mastadon_compartment.id
    vcn_id         = oci_core_vcn.mastadon_vcn.id
    display_name   = "Mastadon DB Server Sub-Network"
}

# ------------------------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------------------------

resource "oci_core_internet_gateway" "mastadon_internet_gw" {
    compartment_id     = oci_identity_compartment.mastadon_compartment.id
    vcn_id             = oci_core_vcn.mastadon_vcn.id
    display_name       = "Mastadon Internet Gateway"
}

resource "oci_core_route_table" "mastadon_public_route_table" {
    compartment_id     = oci_identity_compartment.mastadon_compartment.id
    vcn_id             = oci_core_vcn.mastadon_vcn.id
    display_name       = "Mastadon Public Route Table"
    route_rules {
        network_entity_id  = oci_core_internet_gateway.mastadon_internet_gw.id
        description        = "Allow Internet Access from Mastadon App Servers"
        destination        = "0.0.0.0/0"
        destination_type   = "CIDR_BLOCK"
    }
}

# ------------------------------------------------------------------------------
# NAT Gateway
# ------------------------------------------------------------------------------

resource "oci_core_nat_gateway" "mastadon_NAT_gw" {
    compartment_id     = oci_identity_compartment.mastadon_compartment.id
    vcn_id             = oci_core_vcn.mastadon_vcn.id
    display_name       = "Mastadon NAT Gateway"
}

resource "oci_core_route_table" "mastadon_NAT_route_table" {
    compartment_id     = oci_identity_compartment.mastadon_compartment.id
    vcn_id             = oci_core_vcn.mastadon_vcn.id
    display_name       = "Mastadon Public Route Table"
    route_rules {
        network_entity_id  = oci_core_nat_gateway.mastadon_NAT_gw.id
        description        = "Allow Internet Access from Mastadon DB Servers"
        destination        = "0.0.0.0/0"
        destination_type   = "CIDR_BLOCK"
    }
}

# ------------------------------------------------------------------------------
# Services 
# ------------------------------------------------------------------------------

# Error: 400-RelatedResourceNotAuthorizedOrNotFound, The namespace in the URL
# ('ocid1.compartment.oc1..aaaaaaaax4nkky4yov3bahtf3cg226ya2ngsaru7vxkv6pavdjwzz5udsojq')
# must match the namespace of the account ('sdorfvwhnhvj') or of the compartment
# in the request 
# ('ocid1.compartment.oc1..aaaaaaaax4nkky4yov3bahtf3cg226ya2ngsaru7vxkv6pavdjwzz5udsojq')

resource "oci_objectstorage_bucket" "mastadon_bucket" {
    compartment_id      = oci_identity_compartment.mastadon_compartment.id
    name                = "Mastadon_Object_Storage"
    namespace           = "sdorfvwhnhvj"
}

# Error: 400-LimitExceeded, The following service limits were exceeded:
# file-system-count. Request a service limit increase from the service limits
# page in the console. 
#
#resource "oci_file_storage_file_system" "mastadon_file_system" {
#    compartment_id      = oci_identity_compartment.mastadon_compartment.id
#    availability_domain = "bPBR:AP-SYDNEY-1-AD-1"
#    display_name        = "Mastadon File System"
#}

# ------------------------------------------------------------------------------
# Service Gateway
# ------------------------------------------------------------------------------

resource "oci_core_service_gateway" "mastadon_service_gw" {
    compartment_id     = oci_identity_compartment.mastadon_compartment.id
    vcn_id             = oci_core_vcn.mastadon_vcn.id
    display_name       = "Mastadon_Service_Gateway"
    services {
        service_id     = var.local_services_id
    }
}

# ------------------------------------------------------------------------------
# Availability Domains
# ------------------------------------------------------------------------------

data "oci_identity_availability_domains" "my_ads" {
    compartment_id = var.tenancy_ocid
}
