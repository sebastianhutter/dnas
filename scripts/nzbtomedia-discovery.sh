#!/bin/bash

#
# this script is used by nzbtomedia / sabnzbd to set the necessary configuration settings
# for the nzbtomedia scripts

# the nzbtomedia container will never be restarted after a configuration change
# but the configuration changes still need to be pushed

# import basic bash functions to retrieve information from docker containers
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source /etc/profile.d/etcd.sh
source $DIR/docker_functions.sh
source $DIR/service_functions.sh


# container name
container=nzbtomedia

# basic variables for the etcd service
db_root=/services/nzbtomedia
db_runtime=$db_root/run
db_custom_config=$db_root/config

# variables for other services
sabnzbd_ip=/services/sabnzbd/run/ip
sabnzbd_port=/services/sabnzbd/run/port
sabnzbd_apikey=/services/sabnzbd/run/api_key

couchpotato_ip=/services/couchpotato/run/ip
couchpotato_port=/services/couchpotato/run/port
couchpotato_apikey=/services/couchpotato/run/api_key

sickbeard_ip=/services/sickbeard/run/ip
sickbeard_port=/services/sickbeard/run/port
sickbeard_apikey=/servuces/sickbeard/run/api_key

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
  etcdctl set $db_runtime/workingdir `get_container_volume_path $container /opt/nzbtomedia` > /dev/null
  etcdctl set $db_runtime/config `get_container_volume_path $container /opt/nzbtomedia`/autoProcessMedia.cfg > /dev/null

  # initialise the custom configuration of the service
  echo create config key
  create_db_customconf $db_custom_config

   # copy configuration entries from other services into
  # the services custom configuration.

  #
  # for now I am adding the necessary configuration entries manually into this script
  # it should be added to the etcd configuration for the service so the configuration
  # file does not need to be changed all the time
  #

  echo copy sabnzbd information
  copy_service_configuration $sabnzbd_ip $db_custom_config/[Nzb]/sabnzbd_host
  copy_service_configuration $sabnzbd_port $db_custom_config/[Nzb]/sabnzbd_port
  copy_service_configuration $sabnzbd_apikey $db_custom_config/[Nzb]/sabnzbd_apikey

  echo copy couchpotato information
  copy_service_configuration $couchpotato_ip $db_custom_config/[CouchPotato]/[[movie]]/host
  copy_service_configuration $couchpotato_port $db_custom_config/[CouchPotato]/[[movie]]/port
  copy_service_configuration $couchpotato_apikey $db_custom_config/[CouchPotato]/[[movie]]/apikey
  echo enable nzbtomedia for CouchPotato
  etcdctl set $db_custom_config/[CouchPotato]/[[movie]]/enabled 1

  echo copy sickbeard information
  copy_service_configuration $sickbeard_ip $db_custom_config/[SickBeard]/[[tv]]/host
  copy_service_configuration $sickbeard_port $db_custom_config/[SickBeard]/[[tv]]/port
  #copy_service_configuration $sickbeard_apikey $db_custom_config/[SickBeard]/[[tv]]/apikey
  echo enable nzbtomedia for SickBeard
  etcdctl set $db_custom_config/[SickBeard]/[[tv]]/enabled 1


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
    #reload=1
  fi

  # check if the service needs to be reloaded
  #if [ $reload -eq 1 ]; then
  #  echo reload container
  #  systemctl restart $container
  #fi
fi

# the runtime shouldnt be deleted when the container is stopped.
# the ip, host and api information can still be used by other containers

#if [ "$cmd" = 'stop' ]; then
#  # if stop is executed remove the running configuration of the couchpotato service
#  echo remove running configuration from etcd
#  delete_db_runtime_values $db_runtime
#fi






