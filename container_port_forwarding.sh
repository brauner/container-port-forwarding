#! /bin/sh

# container_port_forwarding:
# Forward a port from host to a container using DNAT.

# Authors:
# Christian Brauner <christian.brauner@mailbox.org>

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.

# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

USAGE="Usage: `basename $0` [-h] {-f host-ip:host-port} [-t container-ip:container-port]"

HOSTIP=
HOSTPORT=80
CONIP=
CONPORT=80

while getopts hf:t: OPT; do
	case "$OPT" in
		h)
			echo $USAGE
			exit 0
			;;
		f)
			HOSTIP="${OPTARG%%:*}"
			HOSTPORT="${OPTARG##*:}"
			;;
		t)
			CONIP="${OPTARG%%:*}"
			CONPORT="${OPTARG##*:}"
			;;
	esac
done

if [ "$#" -lt 2 ]; then
	echo "${USAGE}" >&2
	exit 1
fi

if [ -z "${HOSTIP}" ] || [ -z "${HOSTPORT}" ]; then
	echo "${USAGE}" >&2
        exit 1
fi

if [ -z "${CONIP}" ] || [ -z "${CONPORT}" ]; then
	echo "${USAGE}" >&2
        exit 1
fi

iptables -t nat -A PREROUTING -p tcp -d ${HOSTIP} --dport ${HOSTPORT} -i eth0 -j DNAT --to-destination ${CONIP}:${CONPORT}
iptables -t nat -A POSTROUTING -s ${CONIP} -o eth0 -j SNAT --to ${HOSTIP}
