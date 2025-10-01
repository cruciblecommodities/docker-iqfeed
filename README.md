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
docker run --name iqfeed -e IQFEED_PRODUCT_ID=CHANGEME \
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

This is fairly a opinionated configuration based on my own needs, if you dont like it fork it!

Also some of the code is borrowed and/or inspired from in no particular order
* https://github.com/jaikumarm/docker-iqfeed
* https://github.com/bratchenko/docker-iqfeed
* https://github.com/webanck/docker-wine-steam
* https://github.com/denniskupec/iqfeed-docker
