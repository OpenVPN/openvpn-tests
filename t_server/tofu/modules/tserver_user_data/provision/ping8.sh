#!/bin/sh
#
# Ping the peer. Used by tests 8 and 8a.
#
( sleep 2 ; ping6 -c 2 fd00:abcd:204:8::1 >/dev/null) &
