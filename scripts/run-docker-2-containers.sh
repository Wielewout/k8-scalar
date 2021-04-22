#!/usr/bin/env bash

minikube ssh docker network create cassandra-net

minikube ssh "docker run -d \
    --name cassandra-0-docker \
    --net cassandra-net \
    --hostname cassandra-0-docker \
    -p 9042:9042 \
    --memory=2147484000 \
    --cpu-shares='1024' \
    --cpu-period='100000' \
    --cpu-quota='100000' \
    --user=0 \
    --env=HEAP_NEWSIZE=200M \
    --env=MAX_HEAP_SIZE=1000M \
    --env=CASSANDRA_SEEDS=cassandra-0-docker \
    --env=CASSANDRA_CLUSTER_NAME=thesis-cassandra \
    --env=CASSANDRA_DC=thesis-cassandra-dc \
    --env=CASSANDRA_RACK=thesis-cassandra-rack \
    --env=CASSANDRA_AUTO_BOOTSTRAP=false \
    --env=PATH=/opt/cassandra/bin:/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    --env=LANG=en_US.UTF-8 \
    --env=LANGUAGE=en_US:en \
    --env=LC_ALL=en_US.UTF-8 \
    --env=JAVA_VERSION=jdk8u242-b08 \
    --env=JAVA_HOME=/opt/java/openjdk \
    --env=GOSU_VERSION=1.11 \
    --env=CASSANDRA_HOME=/opt/cassandra \
    --env=CASSANDRA_CONF=/etc/cassandra \
    --env='GPG_KEYS=514A2AD631A57A16DD0047EC749D6EEC0353B12C 	A26E528B271F19B9E5D8E19EA278B781FE4B2BDA 	A4C465FEA0C552561A392A61E91335D77E3E87CB' \
    --env=CASSANDRA_VERSION=2.2.16 \
    --env=CASSANDRA_SHA512=db2026342e876caf790833d49f7ab1a2fbba39bf380384ef66e2da4913f537690a56c97cb2f6ea17f667a0d34aeb406fa658db02aec1121a5ba7134ab59a5cfb \
    --env=CASSANDRA_WRITE_REQUEST_TIMEOUT=20000 \
    --env=CASSANDRA_READ_REQUEST_TIMEOUT=50000 \
    decomads/cassandra:2.2.16"
    
minikube ssh "docker run -d \
    --name cassandra-1-docker \
    --net cassandra-net \
    --hostname cassandra-1-docker \
    --memory=2147484000 \
    --cpu-shares='1024' \
    --cpu-period='100000' \
    --cpu-quota='100000' \
    --user=0 \
    --env=HEAP_NEWSIZE=200M \
    --env=MAX_HEAP_SIZE=1000M \
    --env=CASSANDRA_SEEDS=cassandra-0-docker \
    --env=CASSANDRA_CLUSTER_NAME=thesis-cassandra \
    --env=CASSANDRA_DC=thesis-cassandra-dc \
    --env=CASSANDRA_RACK=thesis-cassandra-rack \
    --env=CASSANDRA_AUTO_BOOTSTRAP=false \
    --env=PATH=/opt/cassandra/bin:/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    --env=LANG=en_US.UTF-8 \
    --env=LANGUAGE=en_US:en \
    --env=LC_ALL=en_US.UTF-8 \
    --env=JAVA_VERSION=jdk8u242-b08 \
    --env=JAVA_HOME=/opt/java/openjdk \
    --env=GOSU_VERSION=1.11 \
    --env=CASSANDRA_HOME=/opt/cassandra \
    --env=CASSANDRA_CONF=/etc/cassandra \
    --env='GPG_KEYS=514A2AD631A57A16DD0047EC749D6EEC0353B12C 	A26E528B271F19B9E5D8E19EA278B781FE4B2BDA 	A4C465FEA0C552561A392A61E91335D77E3E87CB' \
    --env=CASSANDRA_VERSION=2.2.16 \
    --env=CASSANDRA_SHA512=db2026342e876caf790833d49f7ab1a2fbba39bf380384ef66e2da4913f537690a56c97cb2f6ea17f667a0d34aeb406fa658db02aec1121a5ba7134ab59a5cfb \
    --env=CASSANDRA_WRITE_REQUEST_TIMEOUT=20000 \
    --env=CASSANDRA_READ_REQUEST_TIMEOUT=50000 \
    decomads/cassandra:2.2.16"
