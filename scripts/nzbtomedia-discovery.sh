#!/bin/bash

#
# this script is used by nzbtomedia / sabnzbd to set the necessary configuration settings
# for the nzbtomedia scripts

# the nzbtomedia container will never be restarted after a configuration change
# but the configuration changes still need to be pushed

# import basic bash functions to retrieve information from docker containers
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source /etc/profile.d/etcd.sh
source $DIR/etcd_functions.sh
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


cmd=$1
shift
param="$@"

if [ "$cmd" = 'start' ]; then
  unset reload
  unset reload_loop
  unset reload_wait
  unset loop_counter
  unset workingdir
  unset configfile
  unset custom_ini
  unset original_ini
  unset merged_ini

  echo setting container ip
  ip=`get_container_ip $container`
  set_etcd_key "$db_runtime/ip" "$ip"
  echo container ip is \'$ip\'
  echo setting container mac
  mac=`get_container_mac $container`
  set_etcd_key "$db_runtime/mac" "$mac"
  echo container mac is \'$mac\'
  echo setting container published port
  port=`get_container_port $container`
  echo container published port is \'$port\'
  set_etcd_key "$db_runtime/port" "$port"


  echo creating etcd directory \'$db_custom_config\' for custom configuration
  set_etcd_directory $db_custom_config

  echo setting $container working dir
  set_etcd_key "$db_runtime/workingdir" "`get_container_volume_path $container /opt/nzbtomedia`"
  workingdir=`get_etcd_key $db_runtime/workingdir`
  if [ -z $workingdir ]; then
    >&2 echo "could not find the working dir of the nzbtomedia service. the configuration file can not be changed"
  else
    echo setting $container config file
    configfile="$workingdir/autoProcessMedia.cfg"
    set_etcd_key "$db_runtime/config" "$configfile"
    echo container config file is \'$configfile\'

    echo parse config file \'$configfile\'
    original_ini=`read_ini_configuration_file $configfile`

    echo set sabnzbd information for nzbtomedia configuration file
    copy_etcd_key "$sabnzbd_ip" "$db_custom_config/[Nzb]/sabnzbd_host"
    copy_etcd_key "$sabnzbd_port" "$db_custom_config/[Nzb]/sabnzbd_port"
    copy_etcd_key "$sabnzbd_apikey" "$db_custom_config/[Nzb]/sabnzbd_apikey"

    echo set couchpotato information for nzbtomedia configuration file
    copy_etcd_key "$couchpotato_ip" "$db_custom_config/[CouchPotato]/[[movie]]/host"
    copy_etcd_key "$couchpotato_port" "$db_custom_config/[CouchPotato]/[[movie]]/port"
    copy_etcd_key "$couchpotato_apikey" "$db_custom_config/[CouchPotato]/[[movie]]/apikey"
    echo enable couchpotato script for movie tag
    set_etcd_key "$db_custom_config/[CouchPotato]/[[movie]]/enabled" "1"

    echo set sickbeard information for nzbtomedia configuration file
    copy_etcd_key "$sickbeard_ip" "$db_custom_config/[SickBeard]/[[tv]]/host"
    copy_etcd_key "$sickbeard_port" "$db_custom_config/[SickBeard]/[[tv]]/port"
    echo enable sickbeard script for series tag
    set_etcd_key "$db_custom_config/[SickBeard]/[[tv]]/enabled" "1"

    echo parse custom configuration in etcd
    custom_ini=`read_ini_configuration_database $db_custom_config`

    echo compare ini configuration.
    compare_ini_configuration "$original_ini" "$custom_ini" || {
      echo differences found. merge custom configuration to configuration file
      merged_ini=`merge_ini_configuration "$original_ini" "$custom_ini"`

      echo writing configuration file
      write_ini_configuration "$configfile" "$merged_ini" || {
        echo could not write to config file.
      }
    }
  fi
fi