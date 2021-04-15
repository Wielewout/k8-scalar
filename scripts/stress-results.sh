#!/usr/bin/env bash

experiment=${1:-"experiment-controller-0"}
kubectl exec -it ${experiment} -- cat /exp/results--tmp-experiment-properties.dat
