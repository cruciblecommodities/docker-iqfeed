#!/usr/bin/env sh

# Docker HEALTHCHECK. The script only reads: it sends no command to IQConnect.
# Healthy when IQConnect accepts connections on the history port 9100 and the
# S,STATS line of the admin port 9300 (IQConnect sends one each second) gives
# the DTN connection status Connected (field 13).

if ! nc -z -w 2 127.0.0.1 9100 2>/dev/null; then
  echo "unhealthy: 127.0.0.1:9100 does not accept connections"
  exit 1
fi

stats=$(timeout 5 nc -d 127.0.0.1 9300 | grep -m 1 '^S,STATS,')
if [ -z "$stats" ]; then
  echo "unhealthy: no S,STATS line from 127.0.0.1:9300 within 5 s"
  exit 1
fi

status=$(printf '%s\n' "$stats" | cut -d, -f13)
if [ "$status" != "Connected" ]; then
  echo "unhealthy: DTN connection status is '${status}'"
  exit 1
fi

echo "healthy: DTN connection status is Connected"
