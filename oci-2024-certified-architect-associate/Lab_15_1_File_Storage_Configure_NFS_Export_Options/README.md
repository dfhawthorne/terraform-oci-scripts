# Lab 15-1: File Storage: Configure NFS Export Options

## Overview

NFS export options enable you to create more granular access control to limit VCN access. You can use NFS export options to specify access levels for IP addresses or CIDR blocks connecting to file systems through exports in a mount target. Doing this provides better security controls in multi-tenant environments.

Additionally, by using NFS export option access controls, you can limit the clients' ability to connect to the file system and view or write data.

In this lab, you'll learn how to allow read-only access to the file system from one instance and read/write access from the other instance.

In this lab, you'll:

1. Create a Virtual Cloud Network and its components
1. Create two VM instances
1. Create a file system
1. Configure VCN Security Rules for file storage
1. Mount the file system from both the Instances
1. Perform testing

![Lab layout](https://dfhawthorne.github.io/home/oci-2024-architect-associate/storage/describe-file-storage-security/lab-15-1A.png)

## Set Up SSH Connectivity

After the `terraform apply`, run the following commands to establish SSH connectivity to the created VMs:

```bash
mkdir .ssh
echo .ssh >>.gitignore
chmod 700 .ssh
touch .ssh/id_rsa
chmod 600 .ssh/id_rsa
sed -ne '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/p' \
    <(terraform output private_key_pem) \
    >.ssh/id_rsa
ssh -i .ssh/id_rsa opc@$(terraform output -raw vm_01_ip)
ssh -i .ssh/id_rsa opc@$(terraform output -raw vm_02_ip)
```

## Perform Testing

Logs uploaded as:

- [vm_01_test.log](vm_01_test.log) for `VM_01`
- [vm_02_test.log](vm_02_test.log) for `VM_02`

