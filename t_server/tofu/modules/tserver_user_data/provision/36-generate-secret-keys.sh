#!/bin/sh
#
set -e

. $(dirname "$0")/deployment-config.sh

cd "$KEYDIR"

# This is required for "tun-udp-p2p"
for SK in p2p.key; do
    if ! [ -f $KEYDIR/$SK ]; then
        $OPENVPN --genkey secret $SK
    fi
done

# Currently the ta3.key is required by "tun-udp-p2mp-topology-subnet". Other
# servers do not use any tls-auth keys, but we generate one (ta.key) anyways.
for TA in ta.key ta3.key; do
    if ! [ -f $KEYDIR/$TA ]; then
        $OPENVPN --genkey tls-auth $TA
    fi
done

# Currently tc5. key is required by "tun-udp-p2mp-112-mask", but we generate
# tc.key anyways.
for TC in tc.key tc5.key; do
    if ! [ -f $KEYDIR/$TC ]; then
        $OPENVPN --genkey tls-crypt $TC
    fi
done

for TCV2 in tcv2 tcv2-5; do
    if ! [ -f $KEYDIR/$TCV2-server.key ]; then
        $OPENVPN --genkey tls-crypt-v2-server $TCV2-server.key
        $OPENVPN --tls-crypt-v2 $TCV2-server.key --genkey tls-crypt-v2-client $TCV2-client.key

        # Generate tls-crypt-v2 client keys with metadata. This is used to test tls-crypt-v2-verify
        # functionality. Some metadata is considered valid:
        #
        # YWFhYQo= (aaaa): valid
        # YmJiYgo= (bbbb): invalid
        # WFhYWAo= (XXXX): ?
        #
        $OPENVPN --tls-crypt-v2 $TCV2-server.key --genkey tls-crypt-v2-client $TCV2-client-aa.key YWFhYQo=
        $OPENVPN --tls-crypt-v2 $TCV2-server.key --genkey tls-crypt-v2-client $TCV2-client-bb.key YmJiYgo=
        $OPENVPN --tls-crypt-v2 $TCV2-server.key --genkey tls-crypt-v2-client $TCV2-client-XX.key WFhYWAo=
    fi
done

for TCV2_INVALID in tcv2-invalid; do
