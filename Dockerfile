FROM redis/redis-stack-server:latest

# Create the directory for redis configuration files
RUN mkdir -p /usr/local/etc/redis

# Set default value for REDIS_PASSWORD
ENV REDIS_PASSWORD=redispass

# Create separate redis.conf files for each instance
RUN echo "cluster-enabled yes" > /usr/local/etc/redis/redis-7000.conf && \
    echo "cluster-config-file nodes-7000.conf" >> /usr/local/etc/redis/redis-7000.conf && \
    echo "cluster-node-timeout 5000" >> /usr/local/etc/redis/redis-7000.conf && \
    echo "appendonly yes" >> /usr/local/etc/redis/redis-7000.conf && \
    echo "appendfilename appendonly-7000.aof" >> /usr/local/etc/redis/redis-7000.conf && \
    echo "dbfilename dump-7000.rdb" >> /usr/local/etc/redis/redis-7000.conf && \
    echo "requirepass ${REDIS_PASSWORD}" >> /usr/local/etc/redis/redis-7000.conf

RUN echo "cluster-enabled yes" > /usr/local/etc/redis/redis-7001.conf && \
    echo "cluster-config-file nodes-7001.conf" >> /usr/local/etc/redis/redis-7001.conf && \
    echo "cluster-node-timeout 5000" >> /usr/local/etc/redis/redis-7001.conf && \
    echo "appendonly yes" >> /usr/local/etc/redis/redis-7001.conf && \
    echo "appendfilename appendonly-7001.aof" >> /usr/local/etc/redis/redis-7001.conf && \
    echo "dbfilename dump-7001.rdb" >> /usr/local/etc/redis/redis-7001.conf && \
    echo "requirepass ${REDIS_PASSWORD}" >> /usr/local/etc/redis/redis-7001.conf

RUN echo "cluster-enabled yes" > /usr/local/etc/redis/redis-7002.conf && \
    echo "cluster-config-file nodes-7002.conf" >> /usr/local/etc/redis/redis-7002.conf && \
    echo "cluster-node-timeout 5000" >> /usr/local/etc/redis/redis-7002.conf && \
    echo "appendonly yes" >> /usr/local/etc/redis/redis-7002.conf && \
    echo "appendfilename appendonly-7002.aof" >> /usr/local/etc/redis/redis-7002.conf && \
    echo "dbfilename dump-7002.rdb" >> /usr/local/etc/redis/redis-7002.conf && \
    echo "requirepass ${REDIS_PASSWORD}" >> /usr/local/etc/redis/redis-7002.conf

RUN echo "cluster-enabled yes" > /usr/local/etc/redis/redis-7003.conf && \
    echo "cluster-config-file nodes-7003.conf" >> /usr/local/etc/redis/redis-7003.conf && \
    echo "cluster-node-timeout 5000" >> /usr/local/etc/redis/redis-7003.conf && \
    echo "appendonly yes" >> /usr/local/etc/redis/redis-7003.conf && \
    echo "appendfilename appendonly-7003.aof" >> /usr/local/etc/redis/redis-7003.conf && \
    echo "dbfilename dump-7003.rdb" >> /usr/local/etc/redis/redis-7003.conf && \
    echo "requirepass ${REDIS_PASSWORD}" >> /usr/local/etc/redis/redis-7003.conf

RUN echo "cluster-enabled yes" > /usr/local/etc/redis/redis-7004.conf && \
    echo "cluster-config-file nodes-7004.conf" >> /usr/local/etc/redis/redis-7004.conf && \
    echo "cluster-node-timeout 5000" >> /usr/local/etc/redis/redis-7004.conf && \
    echo "appendonly yes" >> /usr/local/etc/redis/redis-7004.conf && \
    echo "appendfilename appendonly-7004.aof" >> /usr/local/etc/redis/redis-7004.conf && \
    echo "dbfilename dump-7004.rdb" >> /usr/local/etc/redis/redis-7004.conf && \
    echo "requirepass ${REDIS_PASSWORD}" >> /usr/local/etc/redis/redis-7004.conf

CMD redis-server /usr/local/etc/redis/redis-7000.conf --port 7000 & \
    redis-server /usr/local/etc/redis/redis-7001.conf --port 7001 & \
    redis-server /usr/local/etc/redis/redis-7002.conf --port 7002 & \
    redis-server /usr/local/etc/redis/redis-7003.conf --port 7003 & \
    redis-server /usr/local/etc/redis/redis-7004.conf --port 7004

