# ------------------------------------------------------------------------------
# OCI Provider details 
# ------------------------------------------------------------------------------

terraform {
    required_providers {
        oci = {
            source = "oracle/oci"
        }
    }
}

# ------------------------------------------------------------------------------
# Configure the Oracle Cloud Infrastructure provider with an API Key
# ------------------------------------------------------------------------------

provider "oci" {
    alias            = "frankfurt"
    tenancy_ocid     = var.provider_details.tenancy_ocid
    user_ocid        = var.provider_details.user_ocid
    fingerprint      = var.provider_details.fingerprint
    private_key_path = var.provider_details.private_key_path
    region           = "eu-frankfurt-1"
}


provider "oci" {
    alias            = "phoenix"
    tenancy_ocid     = var.provider_details.tenancy_ocid
    user_ocid        = var.provider_details.user_ocid
    fingerprint      = var.provider_details.fingerprint
    private_key_path = var.provider_details.private_key_path
    region           = "us-phoenix-1"
}
