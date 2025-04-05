#!/bin/bash

# Setup directories
mkdir -p /data/mgmt_tgt_mgmt01
mkdir -p /data/meta_01_tgt_0101
mkdir -p /data/stor_01_tgt_101
mkdir -p /data/stor_01_tgt_102

# Initialize management service
beegfs-setup-mgmtd -p /data/mgmt_tgt_mgmt01 -C -S mgmt_tgt_mgmt01

# Initialize metadata service
beegfs-setup-meta -p /data/meta_01_tgt_0101 -s 1 -C -S meta_01 -m localhost

# Initialize storage service
beegfs-setup-storage -p /data/stor_01_tgt_101 -s 1 -C -S stor_01_tgt_101 -i 101 -m localhost
beegfs-setup-storage -p /data/stor_01_tgt_102 -s 1 -C -S stor_01_tgt_102 -i 102 -m localhost

# Start services
beegfs-mgmtd
beegfs-meta
beegfs-storage

# Keep container running
tail -f /var/log/beegfs/*.log 