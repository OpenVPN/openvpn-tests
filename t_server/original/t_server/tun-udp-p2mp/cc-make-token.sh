#!/bin/sh
echo "cc USER: $username"
echo "cc PASS: $password"

# on first client-connect, we have no username
# so we use that as trigger for "generate a token and a fake username"
#
# on renegotiation, client connect is not called, so we can not renew
# tokens if using aupv/cc scripts
#
# (this is just a hack to test auth-token-user / override-username,
#  in a secenario *without* "auth-gen-token $secret" - openvpn core will
#  not auto-push "auth-token-user" then, so this must be identical(!) )
#
if [ "$username" = "" ] ; then
    cat <<EOF >$client_connect_config_file
push "auth-token `date +%s`"
override-username MyTokenUser
push "auth-token-user TXlUb2tlblVzZXI="
EOF
fi

exit 0
