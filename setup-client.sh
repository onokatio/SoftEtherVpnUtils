#!/bin/bash -e

if [ "$UID" -ne 0 ]; then
	echo "Run with root!"
	exit 1
fi

function usage_exit(){
	echo "Usage: $0 [-h] [-s <server:port>] [-b <HUB>] [-u <USERNAME>] [-f]"
	echo ""
	echo '  -h                Show this help'
	echo '  -s <server:port>  VPN Server address and port to connect'
	echo '  -b <hub>          VPN HUB Name (Default is "VPN")'
	echo '  -u <username>     VPN Username'
	echo '  -f                Create Account force even if it is already registered.'
	echo $1
	exit 1
}

while getopts hfs:b:u: OPT; do
	case $OPT in
		s) SERVER=$OPTARG ;;
		b) HUB=$OPTARG ;;
		u) USERNAME=$OPTARG ;;
		f) FORCE=1 ;;
		h) usage_exit ;;
		*) usage_exit ;;
	esac
done

if [ -z "$SERVER" ] || [ -z "$HUB" ] || [ -z "$USERNAME" ]; then
	usage_exit "Error: Argment is incorrect."
fi

function client-send(){
	vpncmd localhost /CLIENT /CMD $@
}

if ! client-send NicList | grep "\|vpn0$" >/dev/null 2>&1 ; then
	client-send Niccreate vpn0
	client-send Nicenable vpn0
fi

if client-send AccountList | grep "\|$SERVER-$USERNAME" >/dev/null 2>&1 ; then
	if [ -z "$FORCE" ]; then
		echo "Account is already registered."
		echo "Use -f option to force add account"
		exit 1
	else
		set +e
		client-send AccountDisconnect "$SERVER-$USERNAME"
		set -e
		client-send AccountDelete "$SERVER-$USERNAME"
	fi
fi

client-send AccountCreate $SERVER-$USERNAME /SERVER:$SERVER /HUB:$HUB /USERNAME:$USERNAME /NICNAME:vpn0
client-send AccountPasswordSet $SERVER-$USERNAME /TYPE:standard
client-send AccountConnect $SERVER-$USERNAME

iphead=$(ip addr|grep "scope global vpn_vpn0"|awk '{print $2}'|cut -d '.' -f-3)
if ip r|grep "default"|grep "dev vpn_vpn0"| grep "${iphead}.1" > /dev/null 2>&1 ; then
	ip route del default via ${iphead}.1 dev vpn_vpn0
fi

echo "Please wait..."
dhclient vpn_vpn0

iphead=$(ip addr|grep "scope global vpn_vpn0"|awk '{print $2}'|cut -d '.' -f-3)
if ip r|grep "default"|grep "dev vpn_vpn0"| grep "${iphead}.1" > /dev/null 2>&1 ; then
	ip route del default via ${iphead}.1 dev vpn_vpn0
fi

echo "seccess !"
