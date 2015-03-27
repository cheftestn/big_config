#!/usr/bin/env bash
# Update /etc/hosts

sudo cp /etc/hosts /etc/hosts.bkpz
sudo cp etc_new_hosts /etc/hosts


# Create Directories for NN/DN/JN

sudo mkdir -p /data1/nn /data1/jn /data1/zookeeper

# Change Directory Permissions.

sudo chown hadoopadmin:hadoopadmin /data1/nn
sudo chown hadoopadmin:hadoopadmin /data1/jn
sudo chown hadoopadmin:hadoopadmin /data1/zookeeper
