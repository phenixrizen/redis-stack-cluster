#!/bin/bash

# Set the Redis password, default to 'redispass' if not supplied
REDIS_PASSWORD=${REDIS_PASSWORD:-redispass}




# Create the directory for redis configuration files
mkdir -p /usr/local/etc/redis

# Create separate redis.conf files for each instance
# if the REDIS_SERVICE_HOSTNAME is set, use it for cluster-announce-ip
for port in 7000 7001 7002 7003 7004 7005; do
  {
    echo "bind 0.0.0.0"
    echo "protected-mode no"
    if [ -n "${REDIS_SERVICE_HOSTNAME}" ]; then
      echo "cluster-announce-ip ${REDIS_SERVICE_HOSTNAME}"
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
  --cluster-replicas 1 \
  -a ${REDIS_PASSWORD}

# Keep the script running to prevent the container from exiting
wait