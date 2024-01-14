variable "tenancy_ocid"                           { type = string }
variable "region"                                 { type = string }
variable "default_domain_ocid"                    { type = string }
variable "iam_service_ep"                         { type = string }
variable "domain_license_type"                    { type = string }

variable "user_ocid"                              { type = string }
variable "fingerprint"                            { type = string }
variable "private_key_path"                       { type = string }

variable "mastadon_compartment_description"       { type = string }
variable "mastadon_compartment_name"              { type = string }
variable "mastadon_domain_description"            { type = string }
variable "mastadon_domain_display_name"           { type = string }

variable "local_services_id"                      { type = string }
variable "default_namespace_ocid"                 { type = string }
