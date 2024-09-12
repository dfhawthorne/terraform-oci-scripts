# Lab 12-1: Block Storage: Create, Attach, Detach, and Resize a Block Volume

## Overview

The Oracle Cloud Infrastructure (OCI) Block Volume service lets you dynamically provision and manage block storage volumes. You can create, attach, connect, and move volumes, as well as change volume performance, as needed, to meet your storage, performance, and application requirements.

In this lab, you'll:

- Create a Virtual Cloud Network and its components
- Create a VM instance
- Create a block volume
- Attach a block volume to a compute instance
- Resize a block volume
- Detach a block volume

## Create and Attach Block Volume and Online Resize of Block Volume

![Overview of lab layout with a single VM and block volume](https://dfhawthorne.github.io/home/oci-2024-architect-associate/storage/deploy-and-manage-block-storage/lab-11-1A.png)

## Files

- [main.tf](main.tf)
- [lab12_1.log](lab12_1.log) is the terminal log

## Detaching a Block Volume

I used the following command to detach a block volume:

```bash
oci compute volume-attachment detach --volume-attachment-id=${bv_attach_id}
```
