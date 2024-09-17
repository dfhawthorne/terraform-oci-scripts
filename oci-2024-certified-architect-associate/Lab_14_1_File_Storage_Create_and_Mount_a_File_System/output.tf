# ------------------------------------------------------------------------------
# Lab 14-1: Output variables
# ------------------------------------------------------------------------------

output "private_key_pem" {
    value                       = tls_private_key.ociaalab14key.private_key_pem
    sensitive                   = true
}

output "vm_01_ip" {
    value                       = oci_core_instance.FRA-AA-LAB14-1-VM-01.public_ip
}

output "mount_target_ip_address" {
  value                         = oci_file_storage_mount_target.FRA-AA-LAB14-1-MNT-01.ip_address
}
