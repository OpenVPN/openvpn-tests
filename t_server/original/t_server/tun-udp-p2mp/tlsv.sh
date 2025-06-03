#!/bin/sh
( 
  echo "----------------------------------------"
  date
  echo "tls-verify: $0 $@"
  env |grep peer
  ls -l $peer_cert_2 $peer_cert_1 $peer_cert_0
  openssl x509 -in $peer_cert_2 $peer_cert_1 $peer_cert_0 -noout -text
  echo "---------------------------- END -------"
) | tee -a /tmp/tun-udp-p2mp-tlsv.log

exit 0
