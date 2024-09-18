# ------------------------------------------------------------------------------
# Lab 05-1: Output variables
# ------------------------------------------------------------------------------

output lb_ip_addr {
    value = oci_load_balancer_load_balancer.FRA-AA-LAB-5-LB-01.ip_address_details[0].ip_address
}