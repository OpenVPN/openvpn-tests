#!/bin/bash

set -eux

NETNS=$1
PREFIX=192.168.${NETNS##*-}

[ ! -e /run/netns/$NETNS ] || exit 0

ip netns add $NETNS
NETNS_EXEC="ip netns exec $NETNS"
VETH0="veth${NETNS##*-}e"
VETH1="veth${NETNS##*-}i"

$NETNS_EXEC ip link set dev lo up
ip link add ${VETH0} type veth peer name ${VETH1}
ip link set ${VETH1} netns $NETNS
ip addr add ${PREFIX}.1/24 dev ${VETH0}
ip link set dev ${VETH0} up
$NETNS_EXEC ip addr add ${PREFIX}.2/24 dev ${VETH1}
$NETNS_EXEC ip link set dev ${VETH1} up
$NETNS_EXEC ip route add default via ${PREFIX}.1
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -A POSTROUTING -s ${PREFIX}.0/255.255.255.0 -o eth0 -j MASQUERADE
