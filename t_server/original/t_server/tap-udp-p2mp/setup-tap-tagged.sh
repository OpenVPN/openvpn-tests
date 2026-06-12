#!/bin/sh

export PATH=/bin:/usr/bin:/sbin:/usr/sbin

# make tap interface
ip tuntap add mode tap name tap9
ip link set address 0:2:3:4:5:6 dev tap9

# bring it up
ip link set up dev tap9

# VLAN 209
modprobe 8021q

# 200 tagged
#ip link add link tap9 name tap9.200 type vlan id 200
#ip addr add 10.204.4.1/24 dev tap9.200
#ip addr add fd00:abcd:204:4::1/64 dev tap9.200
#ip link set up dev tap9.200

# 200 untagged
ip addr add 10.204.4.1/24 dev tap9
ip addr add fd00:abcd:204:4::1/64 dev tap9
ip link set up dev tap9

ip link add link tap9 name tap9.207 type vlan id 207
ip addr add 10.207.4.1/24 dev tap9.207
ip addr add fd00:abcd:207:4::1/64 dev tap9.207
ip link set up dev tap9.207
