# Readiness check

## KUBE-POD

> ```sh
> kubectl exec -it cassandra-0 -- bash
> ```

```sh
root@cassandra-0:/# cat /sys/fs/cgroup/cpu,cpuacct/cgroup.procs
1	# java-cassandra
396	# bash session for top
413	# top
414	# bash session to cat cgroup.procs
937	# this cat proc
```

*Used `cat /proc/<pid>/cmdline` to determine process*

Repeatingly additional processes show up which do readiness checks:

```sh
$ kubectl describe statefulset cassandra
$ kubectl describe pod cassandra-0
Readiness:  exec [/bin/bash -c /ready-probe.sh] delay=15s timeout=5s period=10s #success=1 #failure=3

$ kubectl edit statefulset cassandra
        readinessProbe:
          exec:
            command:
            - /bin/bash
            - -c
            - /ready-probe.sh
          failureThreshold: 3
          initialDelaySeconds: 15
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 5
```

> ```sh
> kubectl exec -it cassandra-0 -- bash
> ```

```sh
root@cassandra-0:/# cat /sys/fs/cgroup/cpu,cpuacct/cgroup.procs
1
396
413
414
516	# ready-probe.sh
523	# ready-probe.sh
524	# nodetool (fork ready-probe.sh 524)
525	# grep (fork ready-probe.sh 524)
546	# java-nodetool
561
```



> ```sh
> minikube ssh
> ```

```sh
$ cat /sys/fs/cgroup/cpu,cpuacct/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod<cassandra-0 pod-id>.slice/docker-<cassandra-0 container-id>.scope/cgroup.procs
77089	# java-cassandra
77805	# bash session for top
77870	# bash session for cgroup.procs

$ cat /sys/fs/cgroup/cpu,cpuacct/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod<cassandra-0 pod-id>.slice/docker-<cassandra-0 container-id>.scope/cgroup.procs
77089
77805
77870
94993   # ready-probe.sh
95000   # ready-probe.sh
95001   # nodetool
95002   # grep
95023   # java-nodetool
95037

$ while read pid; do printf "\n$pid\n";cat /proc/"$pid"/cmdline;printf "\n"; done < /sys/fs/cgroup/cpu,cpuacct/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod<cassandra-0 pod-id>.slice/docker-<cassandra-0 container-id>.scope/cgroup.procs

77089
/opt/java/openjdk/bin/java-ea-javaagent:/opt/cassandra/lib/jamm-0.3.0.jar-XX:+CMSClassUnloadingEnabled-XX:+UseThreadPriorities-XX:ThreadPriorityPolicy=42-Xms1000M-Xmx1000M-Xmn200M-XX:+HeapDumpOnOutOfMemoryError-Xss256k-XX:StringTableSize=1000003-XX:+UseParNewGC-XX:+UseConcMarkSweepGC-XX:+CMSParallelRemarkEnabled-XX:SurvivorRatio=8-XX:MaxTenuringThreshold=1-XX:CMSInitiatingOccupancyFraction=75-XX:+UseCMSInitiatingOccupancyOnly-XX:+UseTLAB-XX:+PerfDisableSharedMem-XX:CompileCommandFile=/etc/cassandra/hotspot_compiler-XX:CMSWaitDuration=10000-XX:+CMSParallelInitialMarkEnabled-XX:+CMSEdenChunksRecordAlways-XX:CMSWaitDuration=10000-XX:+PrintGCDetails-XX:+PrintGCDateStamps-XX:+PrintHeapAtGC-XX:+PrintTenuringDistribution-XX:+PrintGCApplicationStoppedTime-XX:+PrintPromotionFailure-Xloggc:/opt/cassandra/logs/gc.log-XX:+UseGCLogFileRotation-XX:NumberOfGCLogFiles=10-XX:GCLogFileSize=10M-Djava.net.preferIPv4Stack=true-Dcassandra.jmx.local.port=7199-XX:+DisableExplicitGC-Djava.library.path=/opt/cassandra/lib/sigar-bin-Dcassandra.libjemalloc=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1-XX:OnOutOfMemoryError=kill -9 %p-Dlogback.configurationFile=logback.xml-Dcassandra.logdir=/opt/cassandra/logs-Dcassandra.storagedir=/opt/cassandra/data-Dcassandra-foreground=yes-cp/etc/cassandra:/opt/cassandra/build/classes/main:/opt/cassandra/build/classes/thrift:/opt/cassandra/lib/ST4-4.0.8.jar:/opt/cassandra/lib/airline-0.6.jar:/opt/cassandra/lib/antlr-runtime-3.5.2.jar:/opt/cassandra/lib/apache-cassandra-2.2.16.jar:/opt/cassandra/lib/apache-cassandra-clientutil-2.2.16.jar:/opt/cassandra/lib/apache-cassandra-thrift-2.2.16.jar:/opt/cassandra/lib/cassandra-driver-core-2.2.0-rc2-SNAPSHOT-20150617-shaded.jar:/opt/cassandra/lib/commons-cli-1.1.jar:/opt/cassandra/lib/commons-codec-1.2.jar:/opt/cassandra/lib/commons-lang3-3.1.jar:/opt/cassandra/lib/commons-math3-3.2.jar:/opt/cassandra/lib/compress-lzf-0.8.4.jar:/opt/cassandra/lib/concurrentlinkedhashmap-lru-1.4.jar:/opt/cassandra/lib/crc32ex-0.1.1.jar:/opt/cassandra/lib/disruptor-3.0.1.jar:/opt/cassandra/lib/ecj-4.4.2.jar:/opt/cassandra/lib/guava-16.0.jar:/opt/cassandra/lib/high-scale-lib-1.0.6.jar:/opt/cassandra/lib/jackson-core-asl-1.9.2.jar:/opt/cassandra/lib/jackson-mapper-asl-1.9.2.jar:/opt/cassandra/lib/jamm-0.3.0.jar:/opt/cassandra/lib/javax.inject.jar:/opt/cassandra/lib/jbcrypt-0.3m.jar:/opt/cassandra/lib/jcl-over-slf4j-1.7.7.jar:/opt/cassandra/lib/jna-4.0.0.jar:/opt/cassandra/lib/joda-time-2.4.jar:/opt/cassandra/lib/json-simple-1.1.jar:/opt/cassandra/lib/libthrift-0.9.2.jar:/opt/cassandra/lib/log4j-over-slf4j-1.7.7.jar:/opt/cassandra/lib/logback-classic-1.1.3.jar:/opt/cassandra/lib/logback-core-1.1.3.jar:/opt/cassandra/lib/lz4-1.3.0.jar:/opt/cassandra/lib/metrics-core-3.1.0.jar:/opt/cassandra/lib/metrics-jvm-3.1.0.jar:/opt/cassandra/lib/metrics-logback-3.1.0.jar:/opt/cassandra/lib/netty-all-4.0.44.Final.jar:/opt/cassandra/lib/ohc-core-0.3.4.jar:/opt/cassandra/lib/ohc-core-j8-0.3.4.jar:/opt/cassandra/lib/reporter-config-base-3.0.0.jar:/opt/cassandra/lib/reporter-config3-3.0.0.jar:/opt/cassandra/lib/sigar-1.6.4.jar:/opt/cassandra/lib/slf4j-api-1.7.7.jar:/opt/cassandra/lib/snakeyaml-1.11.jar:/opt/cassandra/lib/snappy-java-1.1.1.7.jar:/opt/cassandra/lib/stream-2.5.2.jar:/opt/cassandra/lib/super-csv-2.1.0.jar:/opt/cassandra/lib/thrift-server-0.3.7.jar:/opt/cassandra/lib/jsr223/*/*.jarorg.apache.cassandra.service.CassandraDaemon

77805
bash

77870
bash

94993
/bin/bash/ready-probe.sh

95000
/bin/bash/ready-probe.sh

95001
/bin/sh/opt/cassandra/bin/nodetoolstatus

95002
grep172.17.0.6

95023
/opt/java/openjdk/bin/java-javaagent:/opt/cassandra/lib/jamm-0.3.0.jar-ea-cp/etc/cassandra:/opt/cassandra/build/classes/main:/opt/cassandra/build/classes/thrift:/opt/cassandra/lib/ST4-4.0.8.jar:/opt/cassandra/lib/airline-0.6.jar:/opt/cassandra/lib/antlr-runtime-3.5.2.jar:/opt/cassandra/lib/apache-cassandra-2.2.16.jar:/opt/cassandra/lib/apache-cassandra-clientutil-2.2.16.jar:/opt/cassandra/lib/apache-cassandra-thrift-2.2.16.jar:/opt/cassandra/lib/cassandra-driver-core-2.2.0-rc2-SNAPSHOT-20150617-shaded.jar:/opt/cassandra/lib/commons-cli-1.1.jar:/opt/cassandra/lib/commons-codec-1.2.jar:/opt/cassandra/lib/commons-lang3-3.1.jar:/opt/cassandra/lib/commons-math3-3.2.jar:/opt/cassandra/lib/compress-lzf-0.8.4.jar:/opt/cassandra/lib/concurrentlinkedhashmap-lru-1.4.jar:/opt/cassandra/lib/crc32ex-0.1.1.jar:/opt/cassandra/lib/disruptor-3.0.1.jar:/opt/cassandra/lib/ecj-4.4.2.jar:/opt/cassandra/lib/guava-16.0.jar:/opt/cassandra/lib/high-scale-lib-1.0.6.jar:/opt/cassandra/lib/jackson-core-asl-1.9.2.jar:/opt/cassandra/lib/jackson-mapper-asl-1.9.2.jar:/opt/cassandra/lib/jamm-0.3.0.jar:/opt/cassandra/lib/javax.inject.jar:/opt/cassandra/lib/jbcrypt-0.3m.jar:/opt/cassandra/lib/jcl-over-slf4j-1.7.7.jar:/opt/cassandra/lib/jna-4.0.0.jar:/opt/cassandra/lib/joda-time-2.4.jar:/opt/cassandra/lib/json-simple-1.1.jar:/opt/cassandra/lib/libthrift-0.9.2.jar:/opt/cassandra/lib/log4j-over-slf4j-1.7.7.jar:/opt/cassandra/lib/logback-classic-1.1.3.jar:/opt/cassandra/lib/logback-core-1.1.3.jar:/opt/cassandra/lib/lz4-1.3.0.jar:/opt/cassandra/lib/metrics-core-3.1.0.jar:/opt/cassandra/lib/metrics-jvm-3.1.0.jar:/opt/cassandra/lib/metrics-logback-3.1.0.jar:/opt/cassandra/lib/netty-all-4.0.44.Final.jar:/opt/cassandra/lib/ohc-core-0.3.4.jar:/opt/cassandra/lib/ohc-core-j8-0.3.4.jar:/opt/cassandra/lib/reporter-config-base-3.0.0.jar:/opt/cassandra/lib/reporter-config3-3.0.0.jar:/opt/cassandra/lib/sigar-1.6.4.jar:/opt/cassandra/lib/slf4j-api-1.7.7.jar:/opt/cassandra/lib/snakeyaml-1.11.jar:/opt/cassandra/lib/snappy-java-1.1.1.7.jar:/opt/cassandra/lib/stream-2.5.2.jar:/opt/cassandra/lib/super-csv-2.1.0.jar:/opt/cassandra/lib/thrift-server-0.3.7.jar:/opt/cassandra/lib/jsr223/*/*.jar-Xmx1000M-Dcassandra.storagedir=/opt/cassandra/data-Dlogback.configurationFile=logback-tools.xmlorg.apache.cassandra.tools.NodeTool-p7199status
```

When removing the readiness probe, the processes stop occuring in `top` and `cgroup.procs`.

> ```sh
> kubectl exec -it cassandra-0 -- bash
> ```

```sh
root@cassandra-0:/# cat /sys/fs/cgroup/cpu,cpuacct/cgroup.procs
1   # java-cassandra
162 # bash session for top
172 # top
174 # bash session for cgroup.procs
186 # this cat proc
```

## DOCKER-CONTAINER

No additional readiness checks, always get the following result (with increasing pid for cat command)

> ```sh
> minikube ssh
> docker exec -it cassandra-0-docker bash
> ```

```sh
root@cassandra-0-docker:/# cat /sys/fs/cgroup/cpu,cpuacct/cgroup.procs 
1	# java-cassandra
162	# bash session for top
172	# top
173	# bash session to cat cgroup.procs
275	# this cat proc
```
