# Container port forwarding

In order to make web servers and other services running in a container that has
a private IP address publicly addressable we can use destination network
address translation (DNAT). To achieve this we add two additional entries into
our iptables:

```
iptables -t nat -A PREROUTING -p tcp -d ${HOSTIP} --dport ${HOSTPORT} -i eth0 -j DNAT --to-destination ${CONIP}:${CONPORT}
iptables -t nat -A POSTROUTING -s ${CONIP} -o eth0 -j SNAT --to ${HOSTIP}
```

where we specify a public IP of the host with `${HOSTIP}` and a port on the
host with `${HOSTPORT}`. We will use these to allow connections to a service
running in the container. Similarly, we specify a private IP of the container
with `${CONIP}` and a port with `${CONPORT}`. Unfortunately, this has the
consequence that the port `${HOSTPORT}` on the host cannot be accessed from the
internet. To circumvent this we can use source network address translation
(SNAT).

You should be aware that these rules only work for external clients and so you
cannot connect from your local host.
