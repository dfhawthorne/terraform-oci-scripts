# ------------------------------------------------------------------------------
# Lab 13-1:
# Block Storage: Create a Volume Group and Enable Cross Region Replication
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Get Availability Domains
# ------------------------------------------------------------------------------

data "oci_identity_availability_domains" "frankfurt_ads" {
    provider                    = oci.frankfurt
    compartment_id              = var.provider_details.tenancy_ocid
}

data "oci_identity_availability_domains" "london_ads" {
    provider                    = oci.london
    compartment_id              = var.provider_details.tenancy_ocid
}

locals {
    frankfurt_ad1               = data.oci_identity_availability_domains.frankfurt_ads.availability_domains[0].name
    london_ad1                  = data.oci_identity_availability_domains.london_ads.availability_domains[0].name
}

# ------------------------------------------------------------------------------
# Create Block Volumes in Frankfurt
# ------------------------------------------------------------------------------

resource "oci_core_volume" "FRA-AA-LAB13-1-BV-01" {
    provider                    = oci.frankfurt
    availability_domain         = local.frankfurt_ad1
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB13-1-BV-01"
    size_in_gbs                 = 512
    vpus_per_gb                 = 0
}

resource "oci_core_volume" "FRA-AA-LAB13-1-BV-02" {
    provider                    = oci.frankfurt
    availability_domain         = local.frankfurt_ad1
    compartment_id              = var.compartment_id
    display_name                = "FRA-AA-LAB13-1-BV-02"
    size_in_gbs                 = 512
    vpus_per_gb                 = 0
}

# ------------------------------------------------------------------------------
# Create Volume Group in Frankfurt with a replica in London
# ------------------------------------------------------------------------------

resource "oci_core_volume_group" "FRA-AA-LAB13-1-VG-01" {
    provider                    = oci.frankfurt
    compartment_id              = var.compartment_id
    availability_domain         = local.frankfurt_ad1
    display_name                = "FRA-AA-LAB13-1-VG-01"
    
    source_details {
        type                    = "volumeIds"
        volume_ids              = [
            oci_core_volume.FRA-AA-LAB13-1-BV-01.id,
            oci_core_volume.FRA-AA-LAB13-1-BV-02.id
            ]
    }
    volume_group_replicas {
		availability_domain     = local.london_ad1
		display_name            = "LHR-AA-LAB13-1-VGR-01"
	}
}
