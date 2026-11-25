Dockerized IQFeed client with X11VNC for remote viewing
=======================

See [CHANGELOG](./CHANGELOG.md) for a list of notable changes

Usage
-----
Clone this repository and build the image:
```
git clone https://github.com/cruciblecommodities/docker-iqfeed.git
cd docker-iqfeed
docker build . -t iqfeed
```

Run your image with `docker run`
```
docker run --name iqfeed --restart unless-stopped \
    -e IQFEED_PRODUCT_ID=CHANGEME \
    -e IQFEED_LOGIN=CHANGEME \
    -e IQFEED_PASSWORD=CHANGEME \
    -p 5009:5009 -p 9100:9100 -p 9200:9200 -p 9300:9300 -p 9400:9400 \
    -p 5901:5900 \
    -v /var/log/iqfeed:/root/DTN/IQFeed \
    -d iqfeed
```

In docker logs of the container and you should see
```
...
Checking process-compose state at Wed Oct  1 10:40:35 UTC 2025
Project:           398c37414074/root
User:              root
Version:           v1.75.2
Up Time:           30s
Processes:         5
Running Processes: 5
File Names:
         - process-compose.yaml
Status OK. Waiting 10 seconds...
...
```

You can check on the various processes using:

``` sh
$ docker exec -it iqfeed process-compose attach
```

The admin_connection should have lots of logs relating to connection status and similar.

You can connect to the VNC server on port 5901 if you used the settings above (no password).

Restarts and health
-------------------

- **Stale X lock.** At each container start, `entrypoint.sh` removes `/tmp/.X0-lock` and
  `/tmp/.X11-unix/X0` before process-compose starts. A container restart keeps `/tmp`, and Xvfb
  does not start when the old lock names a PID that is alive in the new container. Without Xvfb,
  IQConnect does not start.
- **Liveness.** Every 10 seconds, the entrypoint checks that IQConnect accepts connections on
  the history port `127.0.0.1:9100`. After a start grace of 120 seconds, when the port is closed
  for 300 seconds in sequence, the entrypoint logs
  `Exiting: IQConnect did not accept connections on 127.0.0.1:9100 for <n> s.` and exits with
  status 1. Run the container with a restart policy (for example `--restart unless-stopped`), so
  that Docker starts it again. The DTN connection status has no effect on this check: IQConnect
  reconnects to DTN by itself, and repeated restarts make repeated logins.
- **Health status.** The image `HEALTHCHECK` runs `/usr/local/bin/healthcheck.sh` every 30
  seconds (start period 120 seconds, 3 retries). The container is `healthy` only when port 9100
  accepts connections and the `S,STATS` line on the admin port 9300 gives the DTN connection
  status `Connected`. The script only reads; it sends no command to IQConnect. Docker does not
  act on `unhealthy`. To see the status:

  ``` sh
  $ docker inspect --format '{{.State.Health.Status}}' iqfeed
  $ docker inspect --format '{{json .State.Health.Log}}' iqfeed
  ```

This is fairly a opinionated configuration based on my own needs, if you dont like it fork it!

Also some of the code is borrowed and/or inspired from in no particular order
* https://github.com/jaikumarm/docker-iqfeed
* https://github.com/bratchenko/docker-iqfeed
* https://github.com/webanck/docker-wine-steam
* https://github.com/denniskupec/iqfeed-docker
