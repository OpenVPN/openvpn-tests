#!/bin/sh
cd /root/t_server/tun-udp-p2mp-hash-defscript
exec >>aupv-script.log 2>&1
echo " ------------------"
date
#set
echo "script_type=$script_type"
echo "username=$username / password=$password"
env |egrep "(UV_|auth_)" |sort
if [ "X$1" != "X" ] ; then
	echo "FILE! $1"
	cat $1
fi

# deferred handling?
if [ -n "$UV_WANT_AUV_ASYNC" ] ; then
    echo "Client wants async/deferred handling... (UV_WANT_AUV_ASYNC=$UV_WANT_AUV_ASYNC)"
    if [ -z "$auth_control_file" ] ; then
        echo "no 'auth_control_file' in ENV, FAIL"
        exit 99
    fi
    # tell server we want deferred handling (= it should regularily
    # check that file for updates
    echo 2 >$auth_control_file

    # child process - try simple shell backgrounding
    (
        echo "backgrounded... sleep($UV_WANT_AUV_ASYNC)..."
        sleep "$UV_WANT_AUV_ASYNC"

        # refuse due to env var?
        if [ -n "$UV_WANT_SCRIPT_FAIL" ] ; then
            echo "async done, signal FAIL (UV_WANT_SCRIPT_FAIL=$UV_WANT_SCRIPT_FAIL)!"
            ret=0

        # check auth-password - only a single combo is accepted
        elif [ "X$username" = "Xfbsd-tc-master" -a  \
               "X$password" = "Xtotallysecret" ]
	then
	    echo "ASYNC: password auth passed"
	    ret=1		# all well
	else
	    echo "ASYNC: password auth failed"
	    ret=0		# auth failed
	fi
        echo $ret >$auth_control_file
    ) &

    # parent process - exit 2 needed here!
    exit 2
fi

# --- SYNC ---
# triggered script fail
if [ -n "$UV_WANT_SCRIPT_FAIL" ]
then
    echo "want script fail -> UV_WANT_SCRIPT_FAIL=$UV_WANT_SCRIPT_FAIL"
    test -z "$auth_failed_reason_file" &&
	 auth_failed_reason_file=/dev/null

    if [ $UV_WANT_SCRIPT_FAIL = 99 ]
    then
	R=`cat /root/t_server/tun-udp-p2mp-hash-defscript/seq.txt`
	case $R in
	    1) echo "TEMP[advance no,backoff 5]: R=1" >>$auth_failed_reason_file ; R=2 ;;
	    2) echo "TEMP[advance addr,backoff 2]: R=2" >>$auth_failed_reason_file ; R=3 ;;
	    3) echo "TEMP[backoff 1]: R=3" >>$auth_failed_reason_file ; R=4 ;;
	    *) R=1 ;;	# succeed!
	esac
	echo $R >/root/t_server/tun-udp-p2mp-hash-defscript/seq.txt
	echo "R=$R"
	if [ $R == 1 ] ; then
	    exit 0
	fi
    else
        echo "you stink" >$auth_failed_reason_file
    fi
    exit "$UV_WANT_SCRIPT_FAIL"
fi

# check auth-password - only a single combo is accepted
if [ "X$username" = "Xfbsd-tc-master" -a  \
     "X$password" = "Xtotallysecret" ]
then
    echo "password auth passed (SYNC)"
    exit 0		# all well
else
    echo "password auth failed (SYNC)"
    exit 1		# auth failed
fi
