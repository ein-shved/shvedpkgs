#!@shell@

[ $UID  != 0 ] && SUDO=sudo

url="$($SUDO @p11tool@ --list-token-urls | @grep@ -m1 -o '^.*model=eToken.*$')"

if [ -z $url ]; then
    echo "No matching token found"
    exit 1;
fi

url="$($SUDO @p11tool@ --list-all-certs "$url" | @grep@ -m1 -o 'URL:\s*.*$' |\
       @sed@ 's/URL:\s*//')"

if [ -z $url ]; then
    echo "No matching token found"
    exit 1;
fi

exec $SUDO @openconnect@/bin/openconnect --no-proxy \
    -c "$url" https://cvpn.kaspersky.com

