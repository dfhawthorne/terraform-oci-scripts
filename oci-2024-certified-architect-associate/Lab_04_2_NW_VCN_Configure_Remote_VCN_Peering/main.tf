# ------------------------------------------------------------------------------
# Lab 04-2:
# Networking - Virtual Cloud Network: Configure Remote VCN Peering
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Get services
# ------------------------------------------------------------------------------

data "oci_core_services" "frankfurt" {
    provider                    = oci.frankfurt
}

data "oci_core_services" "phoenix" {
    provider                    = oci.phoenix
}

# ------------------------------------------------------------------------------
# Create first VCN in Frankfurt
# ------------------------------------------------------------------------------

module "vcn_01" {
    source                      = "../create_vcn"
    providers                   = {
        oci                     = oci.frankfurt
    }
    compartment_id              = var.compartment_id
    vcn_details                 = {
        name                    = "FRA-AA-LAB04-2-VCN-01"
        cidr_blocks             = ["172.17.0.0/16"]
        dns_label               = "fraaalab042vcn1"
    }
    public_subnet_details       = {
        cidr_block              = "172.17.0.0/24"
        dns_label               = "public"
    }
    private_subnet_details      = {
        cidr_block              = "172.17.1.0/24"
        dns_label               = "private"
    }
    services_details            = {
        destination             = data.oci_core_services.frankfurt.services[0].cidr_block
        service_id              = data.oci_core_services.frankfurt.services[0].id
    }
    default_route_rules         = [
        {
            destination         = "10.0.0.0/24"
            network_entity_id   = oci_core_drg.drg_vcn_01.id
        }
    ]
    allowable_sources_for_pings = ["10.0.0.0/24"]
    provider_details            = var.provider_details
}

# ------------------------------------------------------------------------------
# Create second VCN in Phoenix
# ------------------------------------------------------------------------------

module "vcn_02" {
    source                      = "../create_vcn"
    providers                   = {
        oci                     = oci.phoenix
    }
    compartment_id              = var.compartment_id
    vcn_details                 = {
        name                    = "PHX-AA-LAB04-2-VCN-01"
        cidr_blocks             = ["10.0.0.0/16"]
        dns_label               = "phxaalab042vcn1"
    }
    public_subnet_details       = {
        cidr_block              = "10.0.0.0/24"
        dns_label               = "public"
    }
    private_subnet_details      = {
        cidr_block              = "10.0.1.0/24"
        dns_label               = "private"
    }
    services_details            = {
        destination             = data.oci_core_services.phoenix.services[0].cidr_block
        service_id              = data.oci_core_services.phoenix.services[0].id
    }
    default_route_rules         = [
        {
            destination         = "172.17.0.0/24"
            network_entity_id   = oci_core_drg.drg_vcn_02.id
        }
    ]
    allowable_sources_for_pings = ["172.17.0.0/24"]
    provider_details            = var.provider_details
}

# ------------------------------------------------------------------------------
# Create Remote Peering Gateways
# ------------------------------------------------------------------------------

resource "oci_core_drg" "drg_vcn_01" {
    provider                = oci.frankfurt
    compartment_id          = var.compartment_id
    display_name            = "FRA-AA-LAB04-2-DRG-01"
}

resource "oci_core_drg" "drg_vcn_02" {
    provider                = oci.phoenix
    compartment_id          = var.compartment_id
    display_name            = "PHX-AA-LAB04-2-DRG-01"
}

resource "oci_core_remote_peering_connection" "rpc_vcn_01" {
    provider                = oci.frankfurt
    compartment_id          = var.compartment_id
    drg_id                  = oci_core_drg.drg_vcn_01.id
    display_name            = "FRA-AA-LAB04-2-RPC-01"
    peer_id                 = oci_core_remote_peering_connection.rpc_vcn_02.id
    peer_region_name        = "us-phoenix-1"
}

resource "oci_core_remote_peering_connection" "rpc_vcn_02" {
    provider                = oci.phoenix
    compartment_id          = var.compartment_id
    drg_id                  = oci_core_drg.drg_vcn_02.id
    display_name            = "PHX-AA-LAB04-2-RPC-01"
}


