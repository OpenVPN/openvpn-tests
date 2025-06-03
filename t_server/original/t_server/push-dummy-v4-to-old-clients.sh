#!/bin/sh
#
cd /root/openvpn-test-server || exit 1
exec >>cc-dummy-v4.out 2>&1
CONF=$1

date
echo "common_name=$common_name"
env |egrep '([IU]V_|ifconfig_|_file)' | sort
echo "--------"

# push dummy IPv4 config to 2.3 or 2.4 test client
V4_NEEDED=
case $IV_VER in
    2.3.*) V4_NEEDED=true ;;
    2.4.*) V4_NEEDED=true ;;
esac

if [ -n "$V4_NEEDED" ] ; then 
    cat <<EOF >>$CONF
push "ifconfig 10.204.5.6 255.255.255.0"
EOF
    echo "IPv4 push (dummy)"
fi

# deferred handling?
if [ -n "$UV_WANT_CCS_ASYNC" ] ; then
    echo "Client wants async/deferred handling... (UV_WANT_CCS_ASYNC=$UV_WANT_CCS_ASYNC)"
    if [ -z "$client_connect_deferred_file" ] ; then
	echo "no 'client_connect_deferred_file' in ENV, FAIL"
	exit 99
    fi
    # tell server we want deferred handling (= it should regularily
    # check that file for updates
    echo 2 >$client_connect_deferred_file

    # child process - try simple shell backgrounding
    ( 
	echo "backgrounded..."
        sleep "$UV_WANT_CCS_ASYNC"
	if [ -n "$UV_WANT_CCS_FAIL" ] ; then
	    echo "async done, signal FAIL (UV_WANT_CCS_FAIL=$UV_WANT_CCS_FAIL)!"
	    ret=0
        else
	    echo "async done, signal success!"
	    ret=1
	fi
	if [ -n "$UV_WANT_CCS_DISABLE" ] ; then
	    echo "... signal 'disable'"
	    echo "disable" >>$CONF
	else
	    echo 'push "setenv CCS_RET meow"' >>$CONF
	    echo 'push "route-ipv6 fd00:dead:beef::1/128"' >>$CONF
	fi
        echo $ret >$client_connect_deferred_file
    ) &

    # parent process
    exit 0
fi

if [ -n "$UV_WANT_CCS_FAIL" ] ; then
    echo "Client requests failure! -> exit($UV_WANT_CCS_FAIL)"
    echo "--------"
    exit $UV_WANT_CCS_FAIL
fi

# all good, sync mode -> set up cc route
echo 'push "route-ipv6 fd00:dead:beef::1/128"' >>$CONF

echo "--------"
exit 0
