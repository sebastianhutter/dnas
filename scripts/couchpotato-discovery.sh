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
container=couchpotato
# basic variables for the etcd service
db_root=/services/couchpotato
db_runtime=$db_root/run
db_custom_config=$db_root/config

# variables for other services
sabnzbd_ip=/services/sabnzbd/run/ip
sabnzbd_port=/services/sabnzbd/run/port
sabnzbd_apikey=/services/sabnzbd/run/api_key

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
  unset reload
  unset workingdir
  reload=0

  # set the docker container run time information
  echo setting container ip
  set_etcd_key "$db_runtime/ip" "`get_container_ip $container`"
  echo setting container mac
  set_etcd_key "$db_runtime/mac" "`get_container_mac $container`"
  echo setting container published port
  set_etcd_key "$db_runtime/port" "`get_container_port $container`"

  # set some additional runtime values
  echo setting couchpotato working dir
  set_etcd_key "$db_runtime/workingdir" "`get_container_volume_path $container /home/couchpotato/.couchpotato`"
  # only set the config file if the working dir is not empty
  workingdir=`get_etcd_key $db_runtime/workingdir`
  if [ ! -z $workingdir ]; then
    echo setting couchpotato config file
    set_etcd_key "$db_runtime/config" "$workingdir/settings.conf"
  fi

  # # now get the couchpotato api key, username and password and store them in the runtime part
  # # those values will be used by other containers to autoconfigure
  # echo set couchpotato api_key, username and password
  # etcdctl set $db_runtime/api_key "$(crudini --get `etcdctl get $db_runtime/config` core api_key)" > /dev/null
  # etcdctl set $db_runtime/username "$(crudini --get `etcdctl get $db_runtime/config` core username)" > /dev/null
  # etcdctl set $db_runtime/password "$(crudini --get `etcdctl get $db_runtime/config` core password)" > /dev/null

  # # initialise the custom configuration of the service
  # echo create config key
  # create_db_customconf $db_custom_config

  # # copy configuration entries from other services into
  # # the services custom configuration.

  # #
  # # for now I am adding the necessary configuration entries manually into this script
  # # it should be added to the etcd configuration for the service so the configuration
  # # file does not need to be changed all the time
  # #
  # echo copy values from other services to the custom configuration
  # echo copy sabnzbd host and api key
  # copy_service_configuration $sabnzbd_ip $db_custom_config/[sabnzbd]/host
  # copy_service_configuration $sabnzbd_port $db_custom_config/[sabnzbd]/host append :
  # copy_service_configuration $sabnzbd_apikey $db_custom_config/[sabnzbd]/api_key


  # # read the custom configuration of the service
  # echo read custom configuration
  # custom_ini=`read_db_customconf_values $db_custom_config`

  # # compare both configurations
  # echo compare differences between service configuration and custom configuration
  # differences=$(compare_configuration `etcdctl get $db_runtime/config` "$custom_ini")

  # # if no differences where detected we do not need to merge the configuration
  # # if differences where detected we need to merge the configuration
  # if [[ ! -z $differences ]]; then
  #   echo merge custom configuration with service configuration
  #   merge_configuration `etcdctl get $db_runtime/config` "$custom_ini"
  #   reload=1
  # fi

  # # check if the service needs to be reloaded
  # if [ $reload -eq 1 ]; then
  #   echo reload container
  #   systemctl restart $container
  # fi
fi

# the runtime shouldnt be deleted when the container is stopped.
# the ip, host and api information can still be used by other containers

#if [ "$cmd" = 'stop' ]; then
#  # if stop is executed remove the running configuration of the couchpotato service
#  echo remove running configuration from etcd
#  delete_db_runtime_values $db_runtime
#fi
