#!/bin/bash

#
# this script is used by the couchpotato discovery service
#
# it writes the necessary information for the couchpotato service
# to the etcd database

# import basic bash functions to retrieve information from docker containers
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source /etc/profile.d/etcd.sh
source $DIR/etcd_functions.sh
source $DIR/docker_functions.sh
source $DIR/service_functions.sh

# container name
container=rssdler

# basic variables for the etcd service
db_root=/services/rssdler
db_runtime=$db_root/run
db_custom_config=$db_root/config

#######
# main
#######

# check if the discovery service is started or stopped

cmd=$1
shift
param="$@"

if [ "$cmd" = 'start' ]; then
  # set the reload variable to 0
  # it determines if the container needs to be restarted - which will happen if the custom configuration changes
  reload=0

  # the plexmedia server can be started by simply running the start script
  # in the plexmedia server lib directory
  # set the docker container run time information
  echo setting docker container runtime information
  set_db_runtime_container_values $container $db_runtime

  # set additional runtime values for the service
  echo set path to service configuration file
  etcdctl set $db_runtime/workingdir `get_container_volume_path $container /var/lib/rssdler` > /dev/null
  etcdctl set $db_runtime/config `get_container_volume_path $container /var/lib/rssdler`/rssdler.conf > /dev/null
  etcdctl set $db_runtime/pid `get_container_volume_path $container /var/lib/rssdler`/workingdir/daemon.info > /dev/null

  # initialise the custom configuration of the service
  echo create config key
  create_db_customconf $db_custom_config

  # read the custom configuration of the service
  echo read custom configuration
  custom_ini=`read_db_customconf_values $db_custom_config`

  # compare both configurations
  echo compare differences between service configuration and custom configuration
  differences=$(compare_configuration `etcdctl get $db_runtime/config` "$custom_ini")

  # if no differences where detected we do not need to merge the configuration
  # if differences where detected we need to merge the configuration
  if [[ ! -z $differences ]]; then
    echo merge custom configuration with service configuration
    merge_configuration `etcdctl get $db_runtime/config` "$custom_ini"
    reload=1
  fi

  # check if the service needs to be reloaded
  if [ $reload -eq 1 ]; then
    echo reload container
    systemctl restart $container
  fi
fi

# the runtime shouldnt be deleted when the container is stopped.
# the ip, host and api information can still be used by other containers

#if [ "$cmd" = 'stop' ]; then
#  # if stop is executed remove the running configuration of the couchpotato service
#  echo remove pid file
#  rm -f `etcdctl get $db_runtime/pid`
#  echo remove running configuration from etcd
#  delete_db_runtime_values $db_runtime
#fi

#rssdler





