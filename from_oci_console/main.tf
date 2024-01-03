provider "oci" {}

resource "oci_core_instance" "generated_oci_core_instance" {
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "DISABLED"
			name = "Vulnerability Scanning"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Oracle Java Management Service"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "OS Management Service Agent"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Management Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute RDMA GPU Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Run Command"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Auto-Configuration"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Authentication"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Block Volume Management"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Bastion"
		}
	}
	availability_config {
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = "bPBR:AP-SYDNEY-1-AD-1"
	compartment_id = "ocid1.compartment.oc1..aaaaaaaamoo6uz2qmix2adls2cgoqxxhdt4wuam3wbcrw6co6z4osweos6da"
	create_vnic_details {
		assign_ipv6ip = "false"
		assign_private_dns_record = "false"
		assign_public_ip = "true"
		subnet_id = "ocid1.subnet.oc1.ap-sydney-1.aaaaaaaabfb6tyssv2t4dxci5mhymomqmrhwdq2nmagdtezfp4ifmbca7c5q"
	}
	display_name = "my_instance"
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
	is_pv_encryption_in_transit_enabled = "true"
	metadata = {
		"ssh_authorized_keys" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDoxxYbWMjB5IUV/AyN0RQCRqgVyoVd1ALwcjNs76ttMw68jUE3ZRU6SFOL2hOl0Bj+6YRlQ6SotRWmHzoLHse0yKBOPQVdqzhgatVryyZhi9PP5xFcN1t3PPBkqqalMrB6jf51FwXNNB2oIoc53/TmUyR7aSqkAoF8/8hVH/HKMwmgE/RYbo7Lcb8qtB/LjmPJDlLURnYuNJdich5Ar31te/OCy6QmI6o8BNgDP3WK/BHpUR4su24AvoLylhuD+O3v9u3y2yRKHDMrTP0En6PsOp19Vg5vDcRuWmDyPS9cXnGRJQHVrjeVlgWhIWHEvZ7PG8XBYgF4iN3/tT5QRjEP /home/douglas/.ssh/oci_admin_rsa"
	}
	shape = "VM.Standard.E2.1.Micro"
	source_details {
		source_id = "ocid1.image.oc1.ap-sydney-1.aaaaaaaavaduzfdla47ukwgoleaefc26ds6olprsl7d2xmfjybjet5k2dxta"
		source_type = "image"
	}
}

