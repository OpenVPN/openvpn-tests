# Introduction

This is an attempt to document the OpenVPN project's "t_server" testbed(s), and
make it accessible to others.

The mid-term plan is to see if it can be templated, so you can checkout
this repo, edit a "vars" file, call "deploy", and have your own instances
running - but this is a bit tricky.

# How does it work

The general principle how the "t_server" testbed works is as follows:

## Virtual machines

There are 3 VMs involved:

1. The "server VM" which builds openvpn, and then starts server instances

1. The "anchor VM" which has one or more long-running openvpn processes
  that connect to the "server VM".  The "anchor VM" serves as a ping
  target, to verify that "client A" can ping "client B".  Also, the
  "anchor VM" typically has multiple extra IP addresses configured on
  its loopback interfaces, so "client -> ping -> iroute(!) -> anchor"
  can test iroute behaviour.

1. The "client VM" which has a number of precompiled OpenVPN binaries
    - depending on what the test should do, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7
      and git master clients, some with a very small set of tests
      ("connect, ping, verify 2.2<->master compatibility, hang up"), some
      with a very long and very detailed list.

## Master script

A master script (t_server.sh) runs this all, out of a daily cron job or on
demand if needed. The actions it takes are the following:

1. The script runs "git pull --rebase" in the "t_server.git/" directory,
   to update to the most recent commit in there - this can be a private
   repo for testing or public, the script does not care.

   (If you have locally applied patches, the script intentionally keeps them,
   so "gerrit work in progress" patches can be cherrypicked and tested)

1. The script then runs "autoreconf -vif" and "configure"
    * configure sets different options depending on weekday, like
      "build with openssl", "mbedtls", "small" - this mostly makes sense
      for the daily runs ("if we break mbedtls, we'll know a few days
      later")

1. Then "make", "make test" with a fairly large "t_client.rc" test set
  (so before we test server functionality, we should be sure that the
  binary just built at least behaves correctly as client)
    * the t_client.rc packed here will need adjustment for every testbed
      of course (certificates, IP addresses to be expected)

1. Results are printed to stdout in a relatively compact format, so 
   "cron job output" is meaningful

1. After building and testing, the resulting src/openvpn/openvpn binary
   is copied to the "the server instances live here" directory
   (/root/t_server/bin/).

1. The server instances running are stopped and restarted by calling
  sudo /root/t_server/stop, sleep, sudo /root/t_server/start

1. The "start" and "stop" script have a list in the scripts of subdirectories
  to process, and will run (relative to /root/t_server/)

     `./bin/openvpn --cd $subdirectory --config server.conf`

1. The script will then delay (by calling "oping -c10 $list_of_ips") a bit
  to give the "anchor VM" time to reconnect.  Pinging anchor IPs will also
  make it visible in the log if a problem happened here.

1. Finally, run "run_t_clients.sh"

    * This script will now shell out to the "client VM" and run multiple
      sets of "t_client.rc" tests, with different OpenVPN binaries (those
      need to be present)

    * The expected file/directory layout on the "client VM" is

        * **~/bin/t_client.sh:** modified t_client.sh from the Distro, which
                                 can handle "I expect this test to FAIL"
                                 (to test backend success/failure stuff)
        * **~/bin/openvpn.<branch>:** openvpn.22, .23, .24, etc
        * **~/t_client.<branch>/t_client.rc:** test set for the relative branches
        * **~/.ssh/authorized_keys:** give ssh access to the "server VM"

# What is in here

In here you can find a number of subdirectories with files from various
existing server instances.

## original

This directory contains the "original" t_server instance, running on a gentoo
system, focusing on "testing everything" - so the server instances have scripts
and plugins that are excercised from the t_client instances, and t_client
instances to test 2.2 to 2.6/master compatibility.

## ubuntu2004

This is "the linux DCO" t_server instance, which mostly tests "the kernel
forwarding side" - so more packet tests, less (or no) backend scripts, plugins,
etc. t_server.sh will build and run the client tests twice, once with
"configure --disable-dco" and once with DCO.

## fbsd14

This is "the FreeBSD DCO" t_server instance, very similar to "the Linux DCO"
instance (but using different IP addresses for everything, so it's easier to
see which instance a given client is talking to)

# Server instances and test families

The server configurations can be found from the *original* subdirectory. Each server configuration maps to a specific test family in t_client.sh:

|Test case family|Server instance|
|--|--|
|1|tun-tcp-p2mp|
|2|tun-udp-p2mp|
|3|tun-udp-p2mp-topology-subnet|
|4|tap-udp-p2mp|
|5|tun-udp-p2mp-112-mask|
|6|tun-udp-p2mp-fragment|
|7|tun-udp-p2mp-global-authpam|
|8|tun-udp-p2p|
|9|tap-tcp-p2p|
|10|tun-udp-p2mp-hash-defscript|
|11|tun-udp-p2p-tls-sha256|

# Test cases

Here's a list of current t_client.sh test cases along with compatibility with different OpenVPN versions.

|Test|2.4|2.5|2.6|2.7|Description|
|:---|---|---|---|---|:----------|
|1a  |   |   |   | Y | TCP / IPv6 / p2mp tun |
|1b  |   |   |   | Y | TCP p2mp tun, IPv4 HTTP proxy |
|2   |   |   |   | Y | UDP / p2mp tun |
|2a  |   |   |   | Y | UDP / p2mp tun, no v4-routes, no NCP |
|2b  |   |   |   | Y | UDP6 / p2mp tun |
|2c  |   |   |   | Y | UDP6 / p2mp tun / --multihome / --redirect-gateway (ipv4, ipv6) |
|2d  |   |   |   | Y | UDP p2mp tun, IPv4 SOCKS proxy |
|2e  |   |   |   | Y | UDP p2mp tun, IPv6 SOCKS proxy |
|2f  |   |   |   | Y | UDP p2mp tun, IPv6-only (--pull-filter) |
|2g  |   |   |   | Y | UDP4 / p2mp tun / --multihome / --redirect-gateway (ipv4, ipv6) |
|2w  |   |   |   | Y | UDP6 / p2mp tun / data-cipher DES-EDE3-CBC |
|2h  |   |   |   | Y | UDP4 / --redirect-gateway (ipv4, ipv6), pre-existing route |
|2x  |   |   |   | Y | UDP4 / p2mp tun / data-cipher none |
|2y  |   |   |   | Y | UDP6 / p2mp tun / --ncp-disable + cipher none |
|2z1 |   |   |   | Y | NCP fail (cipher) |
|2z2 |   |   |   | Y | NCP fail (cipher) |
|3   |   |   |   | Y | UDP / p2mp tun, topology subnet, tls-auth |
|3a  |   |   |   | Y | UDP / p2mp tun, topology subnet, tls-auth, max-packet-size |
|4   |   |   |   |   | UDP / p2mp tap |
|4a  |   |   |   |   | UDP / p2mp tap3 / topo subnet |
|4b  |   |   |   |   | UDP / p2mp tap / ipv6-only |
|5   |   |   |   | Y | UDP / p2mp tun, top net30, ipv6 /112 |
|5a  |   |   |   | Y | udp / p2pm / top net30 / ipv6 only server / async CCS |
|5b  |   |   |   | Y | udp / p2pm / top net30 / ipv6 only server / async PLUGIN |
|5c  |   |   |   | Y | udp / p2pm / top net30 / ipv6 only server / async PLUGIN_V2 |
|5d  |   |   |   | Y | udp / p2pm / top net30 / ipv6 only server / all-async |
|5e  |   |   |   | Y | udp / p2pm / top net30 / ipv6 only server / tls-crypt-v2 |
|5m  |   |   |   | Y | udp / p2pm / top net30 / ipv6 only server / tls-crypt / max-packet-size |
|5n  |   |   |   | Y | udp / p2pm / top net30 / ipv6 only server / tls-crypt-v2 / max-packet-size |
|5u1 |   |   |   |   | udp / p2pm / top net30 / ipv6 only server / tls-crypt-v2 (invalid/bbb) |
|5u2 |   |   |   |   | udp / p2pm / top net30 / ipv6 only server / tls-crypt-v2 (invalid/XX) |
|5v1 |   |   |   | Y | client-connect fail (script) |
|5v2 |   |   |   | Y | client-connect fail (script / async) |
|5v3 |   |   |   | Y | client-connect fail (script / async / reject) |
|5w1 |   |   |   | Y | client-connect fail (plugin) |
|5w2 |   |   |   | Y | client-connect reject (disable) (plugin) |
|5w3 |   |   |   | Y | client-connect fail (plugin + defer) |
|5w4 |   |   |   | Y | client-connect reject (disable) (plugin + defer) |
|5x1 |   |   |   | Y | client-connect fail (plugin_v2) |
|5x2 |   |   |   | Y | client-connect reject (disable) (plugin v2) |
|5x3 |   |   |   | Y | client-connect fail (plugin + defer) |
|5x4 |   |   |   | Y | client-connect reject (disable) (plugin + defer) |
|6   |   |   |   | Y | UDP / p2mp tun, top subnet, --fragment 500 |
|7   |   |   |   |   | UDP / p2mp tun, top subnet, global |
|7a  |   |   |   |   | very long test with auth-token and reneg-sec |
|7b  |   |   |   |   | UDP / p2mp tun, top subnet, global |
|7l  |   |   |   |   | UDP / p2mp tun, top subnet, global, lwip |
|7x  |   |   |   | Y | auth-user-pass fail |
|7x2 |   |   |   | Y | auth-user-pass fail (too long) |
|7y  |   |   |   | Y | auth-user-pass fail (script fail) |
|8   |   |   |   | Y | UDP / p2p tun |
|8a  |   |   |   | Y | IPv6 |
|9   |   |   |   | Y | tcp / p2p tap / --tls-server |
|9a  |   |   |   | Y | udp / p2p tap / --tls-client (no --client) / tcp6 / no pushed cipher |
|10  |   |   |   | Y | UDP / p2mp tun, no CA / FP auth |
|10a |   |   |   | Y | UDP / p2mp tun, no CA / FP auth (deferred) |
|10b |   |   |   | Y | UDP / p2mp tun, no CA / FP auth (fail TEMP) |
|10u |   |   |   | Y | UDP / p2mp tun, no CA / FP auth / wrong password (sync)|
|10v |   |   |   | Y | UDP / p2mp tun, no CA / FP auth / wrong password (async) |
|10w |   |   |   | Y | UDP / p2mp tun, no CA / FP auth / script fail |
|10x |   |   |   |   | UDP / p2mp tun, no CA / FP auth / wrong server FP |
|10z |   |   |   | Y | UDP / p2mp tun, no CA / FP auth (server side only) |
|11  |   |   |   | Y | UDP / p2p tun, TLS, SHA256
|11a |   |   |   | Y | udp / p2p / TLS / SHA256 (BF-only) / v6 |
|11t |   |   |   | Y | udp4 / p2p / TLS / SHA1-SHA256 (NCP) / 400s pre-delay |
|11z |   |   |   | Y | udp / p2p / TLS / none 'lala land' |

# Setup

Setting up this environment has been automated with OpenTofu and Cloud-init.
For details have a look at
[tofu/openvpn_test_env/README.md](tofu/openvpn_test_env/README.md).

# Adding more t_client instances

Different OpenVPN versions support different command-line options, ciphers,
etc. This means that a single t_client.rc file will not work for all of them.
For the same reason some tests will not work on every OpenVPN version.

When you add a new t_client, for example to support a new OpenVPN version, you
need to do several things:

* Create a new t_client.rc for it
* Create certificates and keys for it and point its t_client.rc to those
* Add a ccd file in each applicable server ccd directory

The ccd files are *required* because many t_client tests validate that the client's
VPN IPv4 and/or IPv6 address match their expectations and fail if that is not
the case.
