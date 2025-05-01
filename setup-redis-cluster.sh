#!/bin/bash

# Set the Redis password, default to 'redispass' if not supplied
REDIS_PASSWORD=${REDIS_PASSWORD:-redispass}

# Create the directory for redis configuration files
mkdir -p /usr/local/etc/redis

# Add Redis hostnames and loopback IPs if REDIS_SERVICE_HOSTNAME is set
if [ -n "${REDIS_SERVICE_HOSTNAME}" ]; then
  echo "Configuring loopback IP aliases and /etc/hosts"

  for i in 0 1 2 3 4 5; do
    ip="127.0.0.$((1 + i))"
    hostname="${REDIS_SERVICE_HOSTNAME}${i}"

    # Add loopback alias (ignore error if already exists)
    ip addr add ${ip}/8 dev lo 2>/dev/null || true

    # Add to /etc/hosts if missing
    if ! grep -q "$hostname" /etc/hosts; then
      echo "$ip $hostname" >> /etc/hosts
      echo "Mapped $ip to $hostname"
    fi
  done
fi

# Create redis.conf files
index=0
for port in 7000 7001 7002 7003 7004 7005; do
  {
    if [ -n "${REDIS_SERVICE_HOSTNAME}" ]; then
      echo "bind 127.0.0.$((1 + index))"
    else
      echo "bind 0.0.0.0"
    fi
    echo "protected-mode no"
    if [ -n "${REDIS_SERVICE_HOSTNAME}" ]; then
      echo "cluster-announce-ip ${REDIS_SERVICE_HOSTNAME}${index}"
    fi
    echo "cluster-enabled yes"
    echo "cluster-config-file nodes-${port}.conf"
    echo "cluster-node-timeout 5000"
    echo "appendonly yes"
    echo "appendfilename appendonly-${port}.aof"
    echo "dbfilename dump-${port}.rdb"
    echo "requirepass ${REDIS_PASSWORD}"
    echo "masterauth ${REDIS_PASSWORD}"
    echo "loadmodule /opt/redis-stack/lib/redisearch.so"
    echo "loadmodule /opt/redis-stack/lib/redistimeseries.so"
    echo "loadmodule /opt/redis-stack/lib/rejson.so"
    echo "loadmodule /opt/redis-stack/lib/redisbloom.so"
  } > /usr/local/etc/redis/redis-${port}.conf

  echo "Created configuration file for port ${port}"
  index=$((index + 1))
done

# Verify the creation of configuration files
ls -l /usr/local/etc/redis/

# Start Redis instances
index=0
for port in 7000 7001 7002 7003 7004 7005; do
  if [ -n "${REDIS_SERVICE_HOSTNAME}" ]; then
    bind_ip="127.0.0.$((1 + index))"
  else
    bind_ip="0.0.0.0"
  fi

  redis-server /usr/local/etc/redis/redis-${port}.conf --port ${port} --bind ${bind_ip} --requirepass ${REDIS_PASSWORD} &
  echo "Started Redis instance on $bind_ip:$port"
  index=$((index + 1))
done

# Wait for Redis instances to start
sleep 5

# Create the Redis cluster
if [ -n "${REDIS_SERVICE_HOSTNAME}" ]; then
  echo "yes" | redis-cli --cluster create \
    ${REDIS_SERVICE_HOSTNAME}0:7000 \
    ${REDIS_SERVICE_HOSTNAME}1:7001 \
    ${REDIS_SERVICE_HOSTNAME}2:7002 \
    ${REDIS_SERVICE_HOSTNAME}3:7003 \
    ${REDIS_SERVICE_HOSTNAME}4:7004 \
    ${REDIS_SERVICE_HOSTNAME}5:7005 \
    --cluster-replicas 0 \
    -a ${REDIS_PASSWORD}
else
  echo "yes" | redis-cli --cluster create \
    127.0.0.1:7000 \
    127.0.0.1:7001 \
    127.0.0.1:7002 \
    127.0.0.1:7003 \
    127.0.0.1:7004 \
    127.0.0.1:7005 \
    --cluster-replicas 0 \
    -a ${REDIS_PASSWORD}
fi

# Keep the script running to prevent the container from exiting
wait