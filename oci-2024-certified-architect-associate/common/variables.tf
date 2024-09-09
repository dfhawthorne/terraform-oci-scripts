# Common variable for compartment
variable "compartment_id" {
    type                    = string
    sensitive               = true
    description             = "OCID of OCI compartment"
}


variable "provider_details" {
    type                    = object({
        tenancy_ocid        = string
        user_ocid           = string
        fingerprint         = string
        private_key_path    = string
        region              = string
    })
    sensitive               = true
    description             = "OCI provider details"
}

variable "ssh_public_key" {
    type                    = string
    sensitive               = true
    description             = "Public Key for opc access to compute instance"
}

variable "compute_shape" {
    type                    = string
    description             = "Shape for compute instance"
}