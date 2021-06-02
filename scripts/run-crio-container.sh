#!/usr/bin/env bash

container=${1:-"cassandra-crio-container"}
minikube ssh "sudo podman container create \
    --name ${container} \
    --hostname cassandra-docker \
    -p 9042:9042 \
    --memory=2147484000 \
    --cpu-shares='1024' \
    --cpu-period='100000' \
    --cpu-quota='100000' \
    decomads/cassandra:2.2.16"
    
minikube ssh "sudo podman container start "


sudo podman container create \
    --name cassandra-crio-container \
    --hostname cassandra-docker \
    -p 9042:9042 \
    --memory=2147484000 \
    --cpu-shares='1024' \
    --cpu-period='100000' \
    --cpu-quota='100000' \
    decomads/cassandra:2.2.16
