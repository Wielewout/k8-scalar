#!/usr/bin/env bash

container=${1:-"cassandra-docker-container"}
minikube ssh "docker rm \$(docker stop ${container})"
