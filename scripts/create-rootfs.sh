#!/bin/bash
# Run as sudo?
podman export $(podman create decomads/cassandra:2.2.16) | tar -C rootfs -xvf -
