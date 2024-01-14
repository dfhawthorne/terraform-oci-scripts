# ------------------------------------------------------------------------------
# Terraform script for Retrieving OCI Data
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
# Get OCI Data 
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Availability Domains 
# ------------------------------------------------------------------------------

data "oci_identity_availability_domains" "my_ads" {
  compartment_id = var.tenancy_ocid
}

output "local_ads_names" {
    value = data.oci_identity_availability_domains.my_ads.availability_domains
}

# ------------------------------------------------------------------------------
# Services 
# ------------------------------------------------------------------------------

data "oci_core_services" "my_services" {
}

output "available_services" {
    value = data.oci_core_services.my_services.services
}

# ------------------------------------------------------------------------------
# Name Spaces
# ------------------------------------------------------------------------------

data "oci_identity_tag_namespaces" "default_namespaces" {
    compartment_id = var.tenancy_ocid
}

output "default_namespaces" {
    value = data.oci_identity_tag_namespaces.default_namespaces.tag_namespaces
}

data "oci_identity_compartments" "my_compartments" {
    compartment_id = var.tenancy_ocid
    name           = "mastadon_compartment"
    state          = "ACTIVE"
}

output "mastadon_compartment" {
    value = data.oci_identity_compartments.my_compartments.compartments
}

data "oci_identity_tag_namespaces" "mastadon_namespaces" {
    compartment_id = "ocid1.compartment.oc1..aaaaaaaax4nkky4yov3bahtf3cg226ya2ngsaru7vxkv6pavdjwzz5udsojq"
}

output "mastadon_namespaces" {
    value = data.oci_identity_tag_namespaces.mastadon_namespaces.tag_namespaces
}
