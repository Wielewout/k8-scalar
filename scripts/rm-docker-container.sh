#!/usr/bin/env bash

container=${1:-"cassandra-0-docker"}
minikube ssh "docker rm \$(docker stop ${container})"
