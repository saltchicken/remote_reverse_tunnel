#!/bin/bash

TETHER_INTERFACE="eth1"
WLAN_INTERFACE="wlan0"

TETHER_TARGET="XXXX"
WLAN_TARGET="10.0.0.3"

CHECK_INTERVAL=30

REMOTE_USER="saltchicken"              # Replace with your remote server username
REMOTE_SERVER="10.0.0.3"       # Replace with your remote server's IP or domain
REMOTE_PORT="22"                # Replace with your SSH port (default: 22)
LOCAL_PORT="2222"               # Local port on the remote server for access

is_tunnel_active() {
	pgrep -f "ssh -fN -R 2223:localhost:22" >/dev/null 2>&1
	return $?
}

while true; do
	if is_tunnel_active; then
		echo "SSH tunnel is active."
	else
		echo "SSH tunnel is not active. Checking network interfaces..."

		if ip link show | grep -q "$TETHER_INTERFACE"; then
			echo "$TETHER_INTERFACE detected. Creating SSH tunnel to $TETHER_INTERFACE."
			ssh -fN -R 2223:localhost:22 "$REMOTE_USER@$TETHER_TARGET" -l saltchicken
		elif ip link show | grep -q "$WLAN_INTERFACE"; then
			whoami
			echo "$TETHER_INTERFACE not found, but $WLAN_INTERFACE detected. Creating SSH tunnel to $WLAN_TARGET."
			ssh -fN -R 2223:localhost:22 "$REMOTE_USER@$WLAN_TARGET" -l saltchicken
		else
			echo "Neither interfaces found. Exiting."
			exit 1
		fi
	fi

	sleep $CHECK_INTERVAL
done
