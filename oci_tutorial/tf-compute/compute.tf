# ------------------------------------------------------------------------------
#  Create Compute Image from latest OL8 Image
# ------------------------------------------------------------------------------

resource "oci_core_instance" "ol8_instance" {
    availability_domain         = local.ad1
    compartment_id              = local.compartment_id
    shape                       = var.compute_shape
    shape_config                {
        ocpus                   = 1
        memory_in_gbs           = 6
    }
    source_details {
        source_id               = local.latest_ol8_image_id
        source_type             = "image"
    }
    display_name                = "my_first_instance"
    create_vnic_details {
        assign_public_ip        = true
        subnet_id               = local.public_subnet_id
    }
    metadata = {
        ssh_authorized_keys     = file("/home/douglas/.ssh/oci_admin_rsa.pub")
    } 
}

