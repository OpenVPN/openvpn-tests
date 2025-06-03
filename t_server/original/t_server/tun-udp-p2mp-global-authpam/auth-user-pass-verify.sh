#!/bin/sh
cd /root/t_server/tun-udp-p2mp-global-authpam
exec >>aupv-script.log 2>&1
echo " ------------------"
date
#set
echo "script_type=$script_type"
echo "username=$username / password=$password"
env |grep UV_
if [ "X$1" != "X" ] ; then
	echo "FILE! $1"
	cat $1
fi

# triggered script fail
if [ -n "$UV_WANT_SCRIPT_FAIL" ]
then
    echo "UV_WANT_SCRIPT_FAIL=$UV_WANT_SCRIPT_FAIL"
    exit "$UV_WANT_SCRIPT_FAIL"
fi

exit 0		# all well
