# ------------------------------------------------------------------------------
# Other variables
# ------------------------------------------------------------------------------

# Sandbox Compartment

data "oci_identity_compartments" "sandbox" {
    compartment_id          = var.tenancy_ocid
    name                    = "Sandbox"
}

locals {
    compartment_id          = data.oci_identity_compartments.sandbox.compartments[0].id
}

# Sandbox VCN

data "oci_core_vcns" "sandbox" {
    compartment_id          = local.compartment_id
    display_name            = "Sandbox"
}

locals {
    vcn_id                  = data.oci_core_vcns.sandbox.virtual_networks[0].id
}

# Sandbox Public Subnet

data "oci_core_subnets" "sandbox" {
    compartment_id          = local.compartment_id
    display_name            = "public subnet-Sandbox"
    vcn_id                  = local.vcn_id
}

locals {
    public_subnet_id        = data.oci_core_subnets.sandbox.subnets[0].id
}

# OL8 Compute Images

data "oci_core_images" "ol8_images" {
    compartment_id          = local.compartment_id
    operating_system        = "Oracle Linux"
    operating_system_version = "8"
    shape                   = var.compute_shape
    state                   = "AVAILABLE"
    sort_by                 = "TIMECREATED"
    sort_order              = "DESC"
}

locals {
    latest_ol8_image_id     = data.oci_core_images.ol8_images.images[0].id
}
