# Lab 13-1: Block Storage: Create a Volume Group and Enable Cross Region Replication

## Overview

The Oracle Cloud Infrastructure (OCI) Block Volume service provides you with the capability to group together multiple volumes in a volume group. A volume group can include both types of volumes, boot volumes, which are the system disks for your compute instances, and block volumes, which are for data storage.

In this lab, you'll work with volume groups. You will:

- Create two block volumes
- Create a volume group
- Enable Cross-Region Replication for the volume group
- Activate the Volume Group replica
- Disable replication for a volume group

![Lab layout](https://dfhawthorne.github.io/home/oci-2024-architect-associate/storage/configure-crossregion-replication/lab-13-1A.png)

## Disable Replication for a Volume Group

I used the following OCI CLI commands to disable replication for a volume group (there is only one (1) in the first availability domain in Frankfurt, and the compartment OCID is set as default in the OCI CLI RC profile):

```bash
ad_name=$(                              \
    oci iam availability-domain list    \
        --region eu-frankfurt-1         \
        --query 'data[0].name'          \
        --raw-output                    \
    )
vg_id=$( \
    oci bv volume-group list            \
        --availability-domain=$ad_name  \
        --query 'data[0].id'            \
        --raw-output                    \
        )
oci bv volume-group update              \
    --volume-group-id=$vg_id            \
    --volume-group-replicas='[]'        \
    --force
```

The output was:

```json
{
  "data": {
    "availability-domain": "ZIDs:EU-FRANKFURT-1-AD-1",
    "compartment-id": "ocid1.compartment.oc1..aaaaaaaagbnn457omttfp72djzp3th6capgy5sagqeyssfyjets24fobofyq",
    "defined-tags": {
      "Oracle-Tags": {
        "CreatedBy": "98972735-lab.user01",
        "CreatedOn": "2024-09-14T08:39:44.400Z"
      }
    },
    "display-name": "FRA-AA-LAB13-1-VG-01",
    "freeform-tags": {},
    "id": "ocid1.volumegroup.oc1.eu-frankfurt-1.abtheljr6xmxct4eiffuodhmh6go6r7irid4fq7f2ljdurmjsvqaurdz7dya",
    "is-hydrated": null,
    "lifecycle-state": "UPDATE_PENDING",
    "size-in-gbs": 1024,
    "size-in-mbs": 1048576,
    "source-details": {
      "type": "volumeIds",
      "volume-ids": [
        "ocid1.volume.oc1.eu-frankfurt-1.abtheljrarw5k32ttix5sjnbriodxfzwb56ukwtsju3s4mxggsvnsirsincq",
        "ocid1.volume.oc1.eu-frankfurt-1.abtheljrzuuxvo6acm3mlkdokz2zlpgm4oqrnl56ft7aj2yicu2ipfxs5jdq"
      ]
    },
    "time-created": "2024-09-14T08:39:44.487000+00:00",
    "volume-group-replicas": null,
    "volume-ids": [
      "ocid1.volume.oc1.eu-frankfurt-1.abtheljrarw5k32ttix5sjnbriodxfzwb56ukwtsju3s4mxggsvnsirsincq",
      "ocid1.volume.oc1.eu-frankfurt-1.abtheljrzuuxvo6acm3mlkdokz2zlpgm4oqrnl56ft7aj2yicu2ipfxs5jdq"
    ]
  },
  "etag": "1b7c9d2c2ac87fb10c735c3c15f1171c"
}
```
