#!/bin/sh
#
cd /root/openvpn-test-server || exit 1
exec >>cc.out 2>&1
CONF=$1

date
echo "common_name=$common_name"
env |egrep '[IU]V_' | sort
echo "--------"

# compression autoselect
if [ "$UV_NOCOMP" != "" ] ; then
    cat <<EOF >>$CONF
compress stub-v2
push "compress stub-v2"
    echo "disable compression (poor man's compress migrate)"
EOF

elif [ "$IV_LZ4" = "1" ] ; then 
    cat <<EOF >>$CONF
compress lz4
push "compress lz4"
EOF
    echo "LZ4 autoselect"

elif [ "$IV_SNAPPY" = "1" ] ; then 
    cat <<EOF >>$CONF
compress snappy
push "compress snappy"
EOF
    echo "snappy autoselect"
fi

# not pushable *sigh*
#case $UV_FRAGMENT in
#    [0-9][0-9][0-9]|[0-9][0-9][0-9][0-9])
#	    echo "fragment $UV_FRAGMENT autoselect"
#	    echo "fragment $UV_FRAGMENT" >>$CONF
#	    echo "push \"fragment $UV_FRAGMENT\"" >>$CONF
#            ;;
#    *)      ;;
#esac

# cipher pseudonegotiation for 2.3 clients, with whitelist
case $UV_CIPHER in
    AES-128-CBC|AES-192-CBC|AES-256-CBC)
	    echo "cipher $UV_CIPHER autoselect"
	    echo "cipher $UV_CIPHER" >>$CONF
	    echo "push \"cipher $UV_CIPHER\"" >>$CONF
		;;
    *) ;;
esac

cat $CONF
echo "--------"
exit 0
