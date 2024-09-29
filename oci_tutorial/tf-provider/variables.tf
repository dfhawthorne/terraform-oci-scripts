variable "tenancy_ocid" {
  type 			= string
  sensitive		= true
  description		= "OCID of tenancy"
}

variable "user_ocid" {
  type 			= string
  sensitive		= true
  description		= "OCID of user"
}

variable "private_key_path" {
  type 			= string
  description		= "Path of user private key used for API"
}

variable "fingerprint" {
  type 			= string
  sensitive		= true
  description		= "API fingerprint for user"
}

variable "region" {
  type 			= string
  description		= "OCI region"
}

variable "compartment_id" {
  type 			= string
  sensitive	 	= true
  description 		= "OCID for compartment"
}

