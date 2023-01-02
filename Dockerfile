FROM debian:bullseye-20221219-slim

ENV DNSMASQ_CONFIG_DIR="/etc/dnsmasq.d" \
    DNSMASQ_LOCAL_DOMAIN=local \
    DNSMASQ_DNS_SERVER_1=1.1.1.1 \
    DNSMASQ_DNS_SERVER_2=8.8.8.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    dnsmasq \
    gettext-base \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${DNSMASQ_CONFIG_DIR};

COPY conf/dnsmasq.conf /etc/dnsmasq.conf
COPY conf/dnsmasq.d/*.tmpl /etc/dnsmasq.d/
COPY scripts/*.sh /scripts/

EXPOSE 53/tcp 53/udp
EXPOSE 67/udp

STOPSIGNAL SIGKILL


ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
CMD ["dnsmasq"]