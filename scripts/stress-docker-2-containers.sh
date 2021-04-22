#!/usr/bin/env bash
set -o pipefail
IFS=$'\n\t'

usage() {
echo -n "${BASH_SOURCE[0]} [OPTIONS] [ARGS]

 Performs an experiment to determine the threshhold to start scaling databases.
 
 Parameters:
   userload                             Specify user load or, the start user load, end user load and incrementing interval. (Format:  NN or NN:NN:NN)

 Options:
   -d | --duration              Specify the duration in seconds for each run. (Default: 60)
   -c | --container             The initial container (Default: cassandra-0-docker)
   -e | --experiment		The experiment-controller pod (Default: experiment-controller-0)
   -h | --help                  Display this message

 Note:
   The necessary docker containers and kubernetes pods MUST be running before this script is executed.

 Examples:
   # Stress Cassandra with an user load of 125 requests per seconds for 200 seconds
   ${BASH_SOURCE[0]} --duration 200 125

   # Executes the experiment: 10 users for first run, 20 users for second run, .., 100 users for last run.
   ${BASH_SOURCE[0]} 10:100:10

"
exit 0;
}

## CONSTANTS AND VARIABLE DEFAULTS
ARG_REGEX=^[0-9]*\:[0-9]*\:[0-9]*$
ARG_SINGLE_RUN_REGEX=^[0-9]*$

duration=60
container="cassandra-0-docker"
container1="cassandra-1-docker"
experiment="experiment-controller-0"

request=125
increment=0
limit=125

## HELPER FUNCTIONS
readonly LOG_FILE="/exp/var/logs/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }
cleanup() {
        return
}
get_input() {
        # PARSE INPUT
        while [[ $1 = -?* ]]; do
          case $1 in
                -d|--duration)
                    shift;
                    duration=${1}
                    ;;
                -c|--container)
                    shift;
                    container=${1}
                    ;;
                -e|--experiment)
                    shift;
                    experiment=${1}
                    ;;
                -h|--help) usage >&2; exit 0 ;;
            *)
                        fatal "Flag provided but not defined: '$1'. Use --help to display usage."
          esac
          shift
        done
        args=$@

        # VALIDATE INPUT
        if [ -z flag_date ] && ! [[ $flag_date =~ $DATE_REGEX ]] ; then
                info $flag_date
                fatal "Date flag provided but expected date as YYYYMMDD (eg: 20160628)";
        fi

        # Display help as default when no argument is given
        if [ -z $args ] ; then
                usage >&2;
        fi

        # Normalise args
        if [[ $args =~ $ARG_SINGLE_RUN_REGEX ]] ; then
                args="${args}:${args}:1"
    fi
    
    if ! [[ $args =~ $ARG_REGEX ]] ; then
                fatal "Unexpected argument format. (Expected xx:yy:zz)"
    fi

    request=$(echo $args | awk -F ":" '{ print $1 }')
    increment=$(echo $args | awk -F ":" '{ print $3 }')
    limit=$(echo $args | awk -F ":" '{ print $2 }')
        return
}
setup_experiment() {
	create_keyspace_cmd="cqlsh -e \"CREATE KEYSPACE IF NOT EXISTS scalar WITH replication = {'class':'SimpleStrategy', 'replication_factor':1};\""
	create_table_cmd="cqlsh -e \"CREATE TABLE IF NOT EXISTS scalar.logs (id text PRIMARY KEY, timestamp text, message text);\""
	
        minikube ssh docker exec ${container} ${create_keyspace_cmd}
	minikube ssh docker exec ${container} ${create_table_cmd}
}
setup_run() {
        local user_load=$1
        local duration=$2

        # Create temporary files
        kubectl exec ${experiment} -- cp /exp/etc/experiment-template.properties /tmp/experiment.properties
        kubectl exec ${experiment} -- sed -ie "s@USER_PEAK_LOAD_TEMPLATE@${user_load}@g" /tmp/experiment.properties
        kubectl exec ${experiment} -- sed -ie "s@USER_PEAK_DURATION_TEMPLATE@${duration}@g" /tmp/experiment.properties
        kubectl exec ${experiment} -- sed -ie "s@target_urls=.*\$@target_urls=$(minikube ip)@g" /tmp/experiment.properties
        
        rm -f stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
        
        printf "${user_load} requests per second for ${duration} seconds\n\n${container}: Before\n" >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
	minikube ssh docker exec ${container} cat /sys/fs/cgroup/cpu,cpuacct/cpu.stat >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
	
	printf "\n\n${container1}: Before\n" >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
	minikube ssh docker exec ${container1} cat /sys/fs/cgroup/cpu,cpuacct/cpu.stat >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
}
teardown_run() {
        local user_load=$1

	printf "\n\n${container}: After\n" >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
	minikube ssh docker exec ${container} cat /sys/fs/cgroup/cpu,cpuacct/cpu.stat >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
	
	printf "\n\n${container1}: After\n" >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
	minikube ssh docker exec ${container1} cat /sys/fs/cgroup/cpu,cpuacct/cpu.stat >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
	
	printf "\n\n" >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat
	kubectl exec -it ${experiment} -- cat /exp/results--tmp-experiment-properties.dat >> stress-results/docker2.${request}-${limit}\ \(${increment}\)/results-${user_load}.dat

        # Remove temporary files
        kubectl exec ${experiment} -- rm /tmp/experiment.properties

        # Remove data added to database
        truncate_table_cmd="cqlsh -e \"TRUNCATE scalar.logs;\""
        minikube ssh docker exec ${container} ${truncate_table_cmd}
}
run() {
        local user_load=$1
        local duration=$2

        setup_run $user_load $duration
        kubectl exec ${experiment} -- java -jar /exp/lib/scalar-1.0.0.jar /exp/etc/platform.properties /tmp/experiment.properties
        teardown_run $user_load
}

## MAIN
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
        fatal "Script may not be sourced."
fi
trap cleanup EXIT
get_input $@

setup_experiment

mkdir -p stress-results
mkdir -p stress-results/docker2.${request}-${limit}\ \(${increment}\)

for user_load in $(seq $request $increment $limit)
do
	info "Stressing Cassandra with ${user_load} requests per second for ${duration} seconds"
	run $user_load $duration
done
