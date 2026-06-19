#!/bin/bash

set -eux

NETNS="${1:?netns name required}"
PREFIX="192.168.${NETNS##*-}"

VETH_SUFFIX="${NETNS##*-}"
VETH0="veth${VETH_SUFFIX}e"
VETH1="veth${VETH_SUFFIX}i"
NETNS_PATH="/run/netns/${NETNS}"
NETNS_EXEC="nsenter --net=${NETNS_PATH}"

[ ! -e "${NETNS_PATH}" ] || exit 0

error_exit() {
    set +e
    trap - ERR
    ip link del "${VETH0}"
    ip netns del "${NETNS}"
    exit 1
}
trap error_exit ERR

ip netns add "${NETNS}"

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
