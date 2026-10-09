#!/bin/sh
#
# Usage: t_server.sh [nogit]
#
# Positional parameters:
#
#   nogit: do pull latest code from the remote Git repository
#
# Environment variables
#
#   OPENVPN_GIT_REPO: path to the openvpn Git repository
#
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

. /var/lib/provision/deployment-config.sh
cd $OPENVPN_GIT_REPO || exit 1

# if run from crontab, ensure complete path (fping/fping6!)
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin

CRYPTO=openssl

NUM_VARIANTS=5
# select based on timestamp
[ -n "${VARIANT:-}" ] || VARIANT=$(($(date +%s) % $NUM_VARIANTS + 1))

case $VARIANT in
    1) EXTRA_ARGS= ; VARIANT_NAME=default ;;
    2) EXTRA_ARGS=--enable-small ; VARIANT_NAME=small ;;
    3) EXTRA_ARGS=--enable-iproute2 ; VARIANT_NAME=iproute2 ;;
    #FIXME: --enable-pkcs11 doesn't work on Rocky 9
    4) EXTRA_ARGS="--enable-systemd --enable-selinux --enable-async-push"
       VARIANT_NAME=full ;;
    5) EXTRA_ARGS=--enable-developer-debug ; VARIANT_NAME=debug ;;
    *) exit 1;; # should not happen
esac

echo "using variant $VARIANT_NAME ($VARIANT/$NUM_VARIANTS)"
echo "using crypto $CRYPTO"

if [ "$1" != nogit ]
then
    echo "update git..."
    git pull --rebase || exit 2
    git -P shortlog  HEAD~3..HEAD
fi

echo "autoreconf (quiet)..."
autoreconf -vif >autoreconf.stdout 2>&1
if [ $? != 0 ] ; then
    echo "autoreconf failed, output follows..."
    cat autoreconf.stdout
    exit 10
fi

EXTRA_ARGS="$EXTRA_ARGS --disable-dco --enable-werror"

echo "configure --with-crypto-library=$CRYPTO OPENSSL_CFLAGS="$OPENSSL_CFLAGS" OPENSSL_LIBS="$OPENSSL_LIBS" $EXTRA_ARGS (quiet)..."
./configure --with-crypto-library=$CRYPTO OPENSSL_CFLAGS="$OPENSSL_CFLAGS" OPENSSL_LIBS="$OPENSSL_LIBS" $EXTRA_ARGS >configure.stdout

if [ $? != 0 ] ; then
    echo -e "\n\nconfigure failed, 'tail -20 stdout' follows...\n\n"
    tail -20 configure.stdout
    exit 11
fi

echo "make (quiet)..."
make -j$(nproc) >make.stdout 2>&1
if [ $? != 0 ] ; then
    echo "make failed, output follows..."
    tail -20 make.stdout
    exit 12
fi
src/openvpn/openvpn --version |head -2

#echo "make check (client side, quiet)..."
#make check RUN_SUDO=sudo >>make.stdout 2>&1
#if [ $? != 0 ] ; then
#    echo "make check failed, output follows..."
#    grep -3i FAIL make.stdout
#    echo -e "... going on (could be problem elsewhere)...\n\n";
#fi

#==================
#All 4 tests passed
#==================
#egrep "tests passed|Test sets" make.stdout
#echo ""


echo "restart server processes..."
sudo $SCRIPTPATH/t_server/stop
sleep 14		# wg. multisocket/EEN, issue #702

cp -v src/openvpn/openvpn $BINDIR/openvpn || exit 13

sudo $SCRIPTPATH/t_server/start
#sudo sh -c "setsid /root/t_server/start"

echo "sleep(15), give anchor clients time to reconnect..."
sudo oping -c15 10.204.4.200 fd00:abcd:204:4::a:200 10.207.4.207 fd00:abcd:207:4::a:207

#ssh $HOST 2.3, 2.4, master t_client runs
echo "start client jobs..."
$SCRIPTPATH/run_t_clients.sh
