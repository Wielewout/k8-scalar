#!/bin/bash

minikube ssh docker inspect --format '{{.State.Pid}}' <container-id>
minikube ssh top -p <pid container>

minikube ssh cat /sys/fs/cgroup/cpu,cpuacct/kubepods.slice/kubepods-burstable.slice/<pod-xyz>/docker-<container-id>.slice/cpu.stat

minikube ssh cat /sys/fs/cgroup/cpu,cpuacct/kubepods.slice/kubepods-burstable.slice/<pod-xyz>/cgroups.procs # empty
