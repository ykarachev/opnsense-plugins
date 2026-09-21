#!/bin/sh

# do not pass DNS information that clobbers /etc/resolv.conf
export INTERNAL_IP4_DNS=

# vpnc-script ends with "exit 0", so run it in a subshell: the interface
# rename below must happen after it has configured the tunnel address and
# the routes. Doing the rename in the rc.d script with a fixed sleep is not
# reliable: for the Fortinet protocol vpnc-script only runs after the PPP
# negotiation, which can take longer than any sane sleep, and then the
# rename happens first and leaves the tunnel without an address and routes.
( . /usr/local/sbin/vpnc-script )

case "${reason}" in
connect|reconnect)
	# Give the interface the stable name and the group the plugin
	# registers; a leftover ocvpn0 from a crashed instance would break
	# the rename.
	if ifconfig tun30000 >/dev/null 2>&1; then
		ifconfig ocvpn0 destroy 2>/dev/null
		ifconfig tun30000 name ocvpn0
		ifconfig ocvpn0 group ocvpn
	fi
	;;
esac

# XXX we can register the proper DNS via ifctl(8) if required later
