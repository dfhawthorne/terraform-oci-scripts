# Lab 4-2: Networking - Virtual Cloud Network: Configure Remote VCN Peering

1. Create VCN 01 in Frankfurt using 172.17.0.0/16
   1. Public subnet 172.17.0.0/24
   1. Private subnet 172.17.1.0/24
1. Create VCN 02 in Phoenix using 10.0.0.0/16
   1. Public subnet 10.0.0.0/24
   1. Private subnet 10.1.0.0/24
1. Create DRG 01 in Frankfurt
1. Create DRG 02 in Phoenix
1. Create Remote Peering Connection between DRGs
1. Add route rules:
   1. Route via DRG 01 from VCN 01 to 10.0.0.0/24
   1. Route via DRG 02 from VCN 02 to 172.17.0.0/24
1. Add security rules:
   1. Allow ingress from 10.0.0.0/24 in VCN 01 for PINGs
   1. Allow ingress from 172.17.0.0/24 in VCN 02 for PINGs

