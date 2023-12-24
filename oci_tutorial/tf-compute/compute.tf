resource "oci_core_instance" "ol8_instance" {
    # Required
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = "ocid1.domain.oc1..aaaaaaaavanaepojqowvq6zt4tmluwk4sq6n3obber64pfkjewadnnhmocia"
    shape = "VM.Standard.E2.1.Micro"
    source_details {
        source_id = "ocid1.image.oc1.ap-sydney-1.aaaaaaaavaduzfdla47ukwgoleaefc26ds6olprsl7d2xmfjybjet5k2dxta"
        source_type = "image"
    }

    # Optional
    display_name = "my_first_instance"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = "ocid1.subnet.oc1.ap-sydney-1.aaaaaaaabfb6tyssv2t4dxci5mhymomqmrhwdq2nmagdtezfp4ifmbca7c5q"
    }
    metadata = {
        ssh_authorized_keys = file("/home/douglas/.ssh/oci_admin_rsa.pub")
    } 
    preserve_boot_volume = false
}
