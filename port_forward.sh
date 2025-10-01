#!/usr/bin/env sh

myself=$(hostname -i)
myip=$(grep $myself /etc/hosts | awk '{print $1}')

echo "Forwarding ports on the IP: $myip"

socat -dd tcp-listen:9300,bind=${myip},fork,reuseaddr tcp-connect:127.0.0.1:9300 &
socat -dd tcp-listen:5009,bind=${myip},fork,reuseaddr tcp-connect:127.0.0.1:5009 &
socat -dd tcp-listen:9100,bind=${myip},fork,reuseaddr tcp-connect:127.0.0.1:9100 &
socat -dd tcp-listen:9200,bind=${myip},fork,reuseaddr tcp-connect:127.0.0.1:9200 &
socat -dd tcp-listen:9400,bind=${myip},fork,reuseaddr tcp-connect:127.0.0.1:9400 &
wait
