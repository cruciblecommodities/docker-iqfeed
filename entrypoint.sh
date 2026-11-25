#!/usr/bin/env sh

# Liveness: after the start grace, exit when IQConnect does not accept
# connections on the history port for PORT_DOWN_LIMIT seconds in sequence.
# The Docker restart policy then starts the container again.
START_GRACE=120
PORT_DOWN_LIMIT=300

# Seconds since host boot. A change of the wall clock does not move it.
monotonic_seconds() {
  cut -d. -f1 /proc/uptime
}

cd /root

# A container restart keeps /tmp. Xvfb does not start when /tmp/.X0-lock
# names a PID that is alive in the new container. No Xvfb runs before
# process-compose starts, thus it is safe to remove the lock and the socket.
rm -f /tmp/.X0-lock /tmp/.X11-unix/X0

/usr/local/bin/process-compose --detached-with-tui --detach-on-success -f process-compose.yaml
started=$(monotonic_seconds)
down_since=

while true; do
  echo "Checking process-compose state at $(date)"

  if ! process-compose project state; then
    echo "Error detected! process-compose project state failed."
    break
  fi

  now=$(monotonic_seconds)
  if nc -z -w 2 127.0.0.1 9100 2>/dev/null; then
    down_since=
    echo "Status OK. Waiting 10 seconds..."
  elif [ $((now - started)) -lt "$START_GRACE" ]; then
    echo "Port 127.0.0.1:9100 is closed (start grace). Waiting 10 seconds..."
  else
    down_since=${down_since:-$now}
    down_for=$((now - down_since))
    if [ "$down_for" -ge "$PORT_DOWN_LIMIT" ]; then
      echo "Exiting: IQConnect did not accept connections on 127.0.0.1:9100 for ${down_for} s."
      exit 1
    fi
    echo "Port 127.0.0.1:9100 is closed for ${down_for} s. Waiting 10 seconds..."
  fi

  sleep 10
done

echo "Exiting from entrypoint.."
