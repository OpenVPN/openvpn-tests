#!/bin/sh
cd /home/rocky/openvpn-tests/t_server/original/t_server/tun-udp-p2mp-112-mask
exec >> tlsv2sh.out 2>&1
date
echo $@
env
cat $metadata_file
if grep bbbb $metadata_file ; then
    echo "BBB -> reject"; exit 1;
fi
echo "permit!"
exit 0
