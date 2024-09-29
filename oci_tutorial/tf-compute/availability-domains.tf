# ------------------------------------------------------------------------------
# Get Availability Domains in the Tenancy
# ------------------------------------------------------------------------------

data "oci_identity_availability_domains" "ads" {
    compartment_id              = var.tenancy_ocid
}

locals {
    ad1                         = data.oci_identity_availability_domains.ads.availability_domains[0].name
}
