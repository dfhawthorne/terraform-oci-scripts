# ------------------------------------------------------------------------------
# Lab 08-1: Output variables
# ------------------------------------------------------------------------------

output "private_key_pem" {
    value                       = tls_private_key.ociaalab08key.private_key_pem
    sensitive                   = true
}

output "public_key_pem" {
    value                       = tls_private_key.ociaalab08key.public_key_pem
    sensitive                   = false
}

#output "vm_01_ip" {
#    value                       = oci_core_instance.FRA-AA-LAB08-1-VM-01.public_ip
#}

#output "capacity_reservation_id" {
#    value                       = oci_core_compute_capacity_reservation.FRA-AA-LAB08-1-RESV-01.id
#}
