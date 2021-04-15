#!/usr/bin/env bash

container=${1:-"cassandra-docker-container"}
minikube ssh "docker run -d \
    --name ${container} \
    --hostname cassandra-docker \
    -p 9042:9042 \
    --memory=2147484000 \
    --cpu-shares='1024' \
    --cpu-period='100000' \
    --cpu-quota='100000' \
    decomads/cassandra:2.2.16"
