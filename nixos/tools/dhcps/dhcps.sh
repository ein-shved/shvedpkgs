#!@bash@
IFACE=eth1
ID=1
IP="@ip@"
DNSMASQ="@dnsmasq@"
MKDIR="@mkdir@"
HOSTS=
MASTER=n
CONTROLLER=
VENDOR=

set -e

usage () {
    echo "$0 [ OPTIONS ]"
    echo
    echo "Options:"
    echo "  -i IFNAME  interface, on which dhcp should work"
    echo "  -n NUM     ID of dhcp server, will be used as 3rd octet of subnet"
    echo "  -f FILE    DHCP hostsfile /etc/dhcp/hosts.ID is default"
    echo "  -r         Act as master for relays"
    echo "  -c IP      Controller's address (DHCP option 43)"
    echo "  -m NAME    Vendor's name for DHCP option 43"
    echo "  -h         show this help and exit"
}
cleanup() {
    set +e
    if [ $MASTER != "y" ]; then
        $IP addr del 192.168.$ID.2/24 dev $IFACE
    fi
}

while getopts ":i:n:f:c:m:rh" opt; do
    case $opt in
    i)
      IFACE=$OPTARG
      ;;
    n)
      ID=$OPTARG
      ;;
    f)
      HOSTS=$OPTARG
      ;;
    r)
      MASTER=y
      ;;
    h)
      usage
      exit 0
      ;;
    m)
      VENDOR="$OPTARG"
      ;;
    c)
      CONTROLLER="$OPTARG"
      ;;
    *)
      usage
      exit 1
      ;;
    esac;
done

if [ "x$USER" != xroot ]; then
    IP="sudo $IP"
    DNSMASQ="sudo $DNSMASQ"
    MKDIR="sudo $MKDIR"
fi

if [ -n "$CONTROLLER" ]; then
    OPTION43="--dhcp-option=vendor:$VENDOR,241,$CONTROLLER"
fi

set +e
$IP addr show | grep '192\.168\.'$ID'\.\(.\|..\|...\)' &> /dev/null
RES=$?
if [ $MASTER != "y" ] && [ $RES == 0 ]; then
    echo Subnet of addres 192.168.$ID.2 already in use.
    $IP addr show | grep -B2 '192\.168\.'$ID'\.\(.\|..\|...\)'
    echo Remove it first or choose another ID "(-n)"
    exit 1
fi
set -e

if [ -z $HOSTS ]; then
    $MKDIR -p /etc/dhcp/
    HOSTS=/etc/dhcp/hosts.$ID
fi

trap cleanup EXIT
if [ $MASTER != "y" ]; then
    $IP link set dev $IFACE up
    $IP addr add 192.168.$ID.2/24 dev $IFACE
fi

$DNSMASQ -i $IFACE -d -u $USER -p0 -K --bootp-dynamic               \
    --dhcp-option=6,"8.8.8.8" --dhcp-hostsfile=$HOSTS               \
    --dhcp-option=46,4                                              \
    $OPTION43                                                       \
    --bind-interfaces --dhcp-range=192.168.$ID.100,192.168.$ID.200,255.255.255.0
