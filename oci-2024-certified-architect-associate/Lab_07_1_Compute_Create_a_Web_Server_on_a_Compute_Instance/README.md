# Lab 07-1: Compute: Create a Web Server on a Compute Instance

## Overview

The Oracle Cloud Infrastructure (OCI) Compute lets you provision and manage compute hosts, known as instances. You can launch instances as needed to meet your compute and application requirements. In this lab, you will create a web server on a compute instance.

In this lab, you will:

- Launch Cloud Shell
- Generate SSH keys
- Create a Virtual Cloud Network and its components
- Create a compute instance
- Install an Apache HTTP server on the instance

![Lab layout](https://dfhawthorne.github.io/home/oci-2024-architect-associate/compute/configure-compute-instances/lab-7-1.png)

## Access Compute Instance

I ran the following commands to access the created COMPUTE instance after saving the private key in the lab directory:

```bash
mkdir .ssh
echo .ssh >>.gitignore # Exclude from GIT
chmod 700 .ssh
touch .ssh/id_rsa
chmod 600 .ssh/id_rsa
sed -ne '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/p' \
    <(terraform output private_key_pem) \
    >.ssh/id_rsa
ssh -i .ssh/id_rsa opc@$(terraform output -raw vm_01_ip)
```

## Install Web Server

I ran the following commands to install and configure the web server:

```bash
scp -i .ssh/id_rsa install_web_server.sh opc@$(terraform output -raw vm_01_ip):
ssh -i .ssh/id_rsa opc@$(terraform output -raw vm_01_ip) bash install_web_server.sh
```

The output is attached as [install_web_server.log](install_web_server.log).

## Testing Web Server

I ran the following command to test the Web Server:

```bash
curl http://$(terraform output -raw vm_01_ip)
```

And I got the expected output:

```text
This is my Web-Server running on Oracle Cloud Infrastructure
```
