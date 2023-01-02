# Dnsmasq

Dnsmasq docker container image.

This repo is heavily inspiured by [liip/docker-dnsmasq](https://github.com/liip/docker-dnsmasq)

## Environment Variables

| Variable | Default Value
| --- | ---
| **Server**
| `DNSMASQ_LOCAL_DOMAIN` | `local`
| `DNSMASQ_DNS_SERVER_1` | `1.1.1.1`
| `DNSMASQ_DNS_SERVER_2` | `8.8.8.8`

## Usage example

Here is a sample `docker-compose.yml` file. To enable DHCP the capability `NET_ADMIN` is added. It is also exposed on a manually created macvlan network named `docker_public_services`. Details are well described in the [pi-hole docs](https://docs.pi-hole.net/docker/DHCP/#docker-pi-hole-with-a-macvlan-network). Additional configuration is managed through files located in the `dnsmasq_config` volume. State (namely the DHCP leases) is persisted accross restarts and container upgrades in the `dnsmasq_state` volume.
Please adapt it according to your needs.

```yaml
version: "2.4"
services:
    dnsmasq:
        image: andy008/dnsmasq:0.0.3
        restart: always
        mem_limit: 128m
        cpus: 0.5
        cap_add: ["NET_ADMIN"]
        networks:
            docker_public_services: 
                ipv4_address: "fixed address"
        ports:
            - 53/tcp    #DNS
            - 53/udp    #DNS  
            - 67:67/udp #DHCP
        volumes:
            -  type: volume
               source: dnsmasq_config
               target: /etc/dnsmasq.d/
               read_only: false 
            -  type: volume
               source: dnsmasq_state
               target: /var/dnsmasq/state
               read_only: false 
        
networks:
    docker_public_services:
        external: true

volumes:
    dnsmasq_config:
       driver: local
    dnsmasq_state:
       driver: local
```

Additional configuration files can be mounted in `/etc/dnsmasq.d/` and will be loaded automatically (dnsmasq will take everything that ends wit `*.conf`). Here is a sample:

```
# Be nice to upstream
domain-needed
bogus-priv

# Don't use container /etc/hosts to resolve local DNS queriesand use other file instead
no-hosts
addn-hosts=/etc/dnsmasq.d/local-dns-entries

# use wildcard DNS
address=/.mydomain.com/192.168.1.44

# file to persist leases
dhcp-leasefile=/var/dnsmasq/state/dnsmasq.leases

```