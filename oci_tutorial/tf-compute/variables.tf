# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

variable "tenancy_ocid" {
    type            = string
    sensitive       = true
    description     = "OCID of Tenancy"
}

variable "user_ocid" {
    type            = string
    sensitive       = true
    description     = "OCID of User"
}

variable "private_key_path" {
  type              = string
    sensitive       = false
    description     = "Path to API Private Key"
}

variable "fingerprint" {
  type              = string
    sensitive       = true
    description     = "Fingerprint for API Private Key"
}

variable "region" {
    type            = string
    sensitive       = false
    description     = "OCI Region"
}

variable "compute_shape" {
    type            = string
    sensitive       = false
    description     = "Name of compute shape"
}

