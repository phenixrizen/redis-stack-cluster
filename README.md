# Redis Stack Cluster Docker Container

This repository contains a Dockerfile to create a Redis Cluster using Redis Stack. The cluster consists of multiple Redis instances, each with its own configuration file. The container is built and published to Docker Hub using GitHub Actions.

## Features

- Redis Cluster with multiple instances
- Configurable Redis password
- Automated build and publish to Docker Hub using GitHub Actions

## Prerequisites

- Docker
- Docker Hub account (for publishing the Docker image)

## Getting Started

### Building the Docker Image

To build the Docker image locally, run the following command:

```sh
docker build -t phenixrizen/redis-stack-cluster:latest .
```

### Running the Docker Container

To run the Docker container, use the following command:

```sh
docker run -e REDIS_PASSWORD=mysecretpassword -d phenixrizen/redis-stack-cluster:latest
```

### Accessing Redis Instances

The Redis instances will be running on the following ports:

- 7000
- 7001
- 7002
- 7003
- 7004

You can connect to any of these instances using a Redis client:

```sh
redis-cli -p 7000 -a mysecretpassword
```