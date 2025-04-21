#!/bin/bash

# Set the Redis password, default to 'redispass' if not supplied
REDIS_PASSWORD=${REDIS_PASSWORD:-redispass}

# Create the directory for redis configuration files
mkdir -p /usr/local/etc/redis

# Add Redis hostnames to the end of the 127.0.0.1 line in /etc/hosts
if [ -n "${REDIS_SERVICE_HOSTNAME}" ]; then
  echo "Updating /etc/hosts with Redis hostnames"
  
  # Build list of needed hostnames
  redis_hosts=()
  for i in 0 1 2 3 4 5; do
    if [ "$i" -eq 0 ]; then
      redis_hosts+=("${REDIS_SERVICE_HOSTNAME}")
    else
      redis_hosts+=("${REDIS_SERVICE_HOSTNAME}${i}")
    fi
  done

  # Read and modify /etc/hosts
  if grep -q "^127.0.0.1" /etc/hosts; then
    # Extract current line
    current_line=$(grep "^127.0.0.1" /etc/hosts)
    updated_line="$current_line"

    for h in "${redis_hosts[@]}"; do
      if ! grep -qE "(^127\.0\.0\.1\s|^127\.0\.0\.1\s.*\s)${h}(\s|$)" /etc/hosts; then
        updated_line="$updated_line $h"
      fi
    done

    # Replace the line if it changed
    if [ "$updated_line" != "$current_line" ]; then
      sed -i.bak "/^127.0.0.1/c\\$updated_line" /etc/hosts
      echo "Updated /etc/hosts: $updated_line"
    else
      echo "All hostnames already present in /etc/hosts"
    fi
  else
    echo "127.0.0.1 ${redis_hosts[*]}" >> /etc/hosts
    echo "Added new 127.0.0.1 line to /etc/hosts"
  fi
fi

# Create separate redis.conf files for each instance
# if the REDIS_SERVICE_HOSTNAME is set, use it for cluster-announce-ip
index=0
for port in 7000 7001 7002 7003 7004 7005; do
  {
    echo "bind 0.0.0.0"
    echo "protected-mode no"
    if [ -n "${REDIS_SERVICE_HOSTNAME}" ]; then
      if [ "$index" -eq 0 ]; then
        echo "cluster-announce-ip ${REDIS_SERVICE_HOSTNAME}"
      else
        echo "cluster-announce-ip ${REDIS_SERVICE_HOSTNAME}${index}"
      fi
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
for port in 7000 7001 7002 7003 7004 7005; do
  redis-server /usr/local/etc/redis/redis-${port}.conf --port ${port} --requirepass ${REDIS_PASSWORD} &
  echo "Started Redis instance on port ${port}"
done

# Wait for Redis instances to start
sleep 5

# Create the Redis cluster
echo "yes" | redis-cli --cluster create \
  127.0.0.1:7000 \
  127.0.0.1:7001 \
  127.0.0.1:7002 \
  127.0.0.1:7003 \
  127.0.0.1:7004 \
  127.0.0.1:7005 \
  --cluster-replicas 0 \
  -a ${REDIS_PASSWORD}

# Keep the script running to prevent the container from exiting
wait