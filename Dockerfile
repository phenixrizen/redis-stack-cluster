FROM redis/redis-stack-server:latest

# Copy the cluster setup script
COPY setup-redis-cluster.sh /usr/local/bin/setup-redis-cluster.sh
RUN chmod +x /usr/local/bin/setup-redis-cluster.sh

# Start Redis instances and set up the cluster
CMD /usr/local/bin/setup-redis-cluster.sh