FROM ubuntu:noble

WORKDIR /root/
ENV HOME=/root

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

ENV WINEPREFIX=/root/.wine
ENV DISPLAY=:0

ENV IQFEED_INSTALLER_BIN="iqfeed_client_6_2_1_29.exe"
ENV IQFEED_LOG_LEVEL=0xB222

ENV WINEDEBUG=-all

EXPOSE 5009 9100 9200 9300 9400 5900

# Add i386 and update
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get upgrade -yq

# Install basic and X11 related packages
RUN apt-get install -yq --no-install-recommends \
        software-properties-common apt-utils wget tar gpg-agent \
        curl git netcat-openbsd net-tools socat \
        xvfb x11vnc xdotool && \
    # Cleaning up.
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install python related packages
RUN apt-get update && \
    apt-get install -yq --no-install-recommends python3 python3-setuptools python3-numpy && \
    # Cleaning up.
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install winehq-stable
RUN mkdir -pm755 /etc/apt/keyrings && \
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key - && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources && \
    apt-get update && apt-get install -yq --no-install-recommends winehq-stable && \
    apt-get install -yq --no-install-recommends winbind winetricks cabextract && \
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
	chmod +x winetricks && mv winetricks /usr/local/bin && \
    # Cleaning up.
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Init wine instance
RUN winecfg && wineserver --wait

# Install iqfeed client
RUN mkdir -p /root/DTN/IQFeed && \
    wget -nv http://www.iqfeed.net/$IQFEED_INSTALLER_BIN -O /root/$IQFEED_INSTALLER_BIN && \
    xvfb-run -s -noreset -a wine64 /root/$IQFEED_INSTALLER_BIN /S && \
    wineserver --wait && \
    rm -rf /root/.wine/.cache && \
    rm -f /root/$IQFEED_INSTALLER_BIN

# Install pyiqfeed
RUN git clone https://github.com/cruciblecommodities/pyiqfeed.git && \
    cd pyiqfeed && \
    python3 setup.py install && \
    cd .. && rm -rf pyiqfeed

# Install process-compose
RUN sh -c "$(curl --location https://raw.githubusercontent.com/F1bonacc1/process-compose/main/scripts/get-pc.sh)" -- -d -b /usr/local/bin

ADD pyiqfeed_admin_conn.py /root/pyiqfeed_admin_conn.py
ADD run_iqfeed.sh /root/run_iqfeed.sh
ADD port_forward.sh /root/port_forward.sh
ADD process-compose.yaml /root/process-compose.yaml
ADD entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh" ]
