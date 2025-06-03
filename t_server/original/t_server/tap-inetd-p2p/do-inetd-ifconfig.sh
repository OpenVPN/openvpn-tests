#!/bin/sh

IF=$1
ifconfig $IF up
ip addr add 10.204.9.1/24 dev $IF
ip addr add fd00:abcd:204:9::1/64 dev $IF
