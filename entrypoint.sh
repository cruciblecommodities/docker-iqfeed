#!/usr/bin/env sh

cd /root
/usr/local/bin/process-compose --detached-with-tui --detach-on-success -f process-compose.yaml

while true; do
  echo "Checking process-compose state at $(date)"

  if ! process-compose project state; then
    echo "Error detected! process-compose project state failed."
    break
  fi

  echo "Status OK. Waiting 10 seconds..."
  sleep 10
done

echo "Exiting from entrypoint.."
