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
container=sabnzbd

# basic variables for the etcd service
db_root=/services/sabnzbd
db_runtime=$db_root/run
db_custom_config=$db_root/config

# variables for other services
#sabnzbd_ip=/services/sabnzbd/run/ip
#sabnzbd_port=/services/sabnzbd/run/port
#sabnzbd_apikey=/services/sabnzbd/run/api_key

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
  unset reload_loop
  unset reload_wait
  unset workingdir
  unset configfile
  unset custom_ini
  unset original_ini
  unset merged_ini

  # set the reload variable to zero
  reload=0
  # the reload loop variable is used to push the reload
  # of the container a little bit.
  # the container will only be rebooted after it went trough the config
  # loop n times
  reload_loop=3
  # the reload_wait variable defines the time between the configuration loops
  # in seconds
  reload_wait=10

  # the plexmedia server can be started by simply running the start script
  # in the plexmedia server lib directory
  # set the docker container run time information
  # set the docker container run time information
  echo setting container ip
  set_etcd_key "$db_runtime/ip" "`get_container_ip $container`"
  echo setting container mac
  set_etcd_key "$db_runtime/mac" "`get_container_mac $container`"
  echo setting container published port
  set_etcd_key "$db_runtime/port" "`get_container_port $container`"

   # if the etcd directory for the custom configuration does not exist create
  # it now.
  echo creating etcd directory for custom configuration
  set_etcd_directory $db_custom_config

  # set some additional runtime values
  echo setting $container working dir
  set_etcd_key "$db_runtime/workingdir" "`get_container_volume_path $container /home/sabnzbd/.sabnzbd`"
  # only set the config file if the working dir is not empty
  workingdir=`get_etcd_key $db_runtime/workingdir`
  if [ -z $workingdir ]; then
    >&2 echo "could not find the working dir of the sabnzbd service. the configuration file can not be changed"
  else
    # for now we can guarantee that the configuration file can only exist
    # if we can find the specified workingdir.
    echo setting $container config file
    configfile="$workingdir/sabnzbd.ini"
    set_etcd_key "$db_runtime/config" "$configfile"

    # now read the original ini file.
    original_ini=`read_ini_configuration_file $configfile`

    # now read the custom configuraton
    custom_ini=`read_ini_configuration_database $db_custom_config`

    # set some additiona values which will be needed by other services
    # if the values cant be found in the ini file the values will be set empty
    echo set the sabnzbd api key, username and password
    set_etcd_key $db_runtime/api_key "`crudini --get <(echo -e $original_ini) misc api_key 2>/dev/null || >&2 echo couldnt find api key in config`"
    set_etcd_key $db_runtime/username "`crudini --get <(echo -e $original_ini) misc username 2>/dev/null || >&2 echo couldnt find api key in config`"
    set_etcd_key $db_runtime/password "`crudini --get <(echo -e $original_ini) misc password 2>/dev/null || >&2 echo couldnt find api key in config`"

    # now compare the ini file with the custom configuration from the db
    # if differences are detected (from the custom configuration in the db to the ini file)
    # the differences will be merged into the configuration file
    echo compare ini configuration
    compare_ini_configuration "$original_ini" "$custom_ini" || {
      echo differences found. merge custom configuration to configuration file
      merged_ini=`merge_ini_configuration "$original_ini" "$custom_ini"`

      ##
      ## write back function missing
      ##

    }

    # if the container needs to be reloaded execute a systemctl restart
    if [ $reload -eq 1 ]; then
      echo reload container $container
      systemctl restart $container
    fi

  fi


#  echo -e $custom_ini
#
#  echo -e $original_ini
#
# what happens when the configuration file is not found
#
#
# #
# #

#   # now get the couchpotato api key, username and password and store them in the runtime part
#   # those values will be used by other containers to autoconfigure
#   echo set sabnzbd api_key, username and password
#   # create a temporary config file and make it parseable for crudini
#   temporary_service_configuration_path=`etcdctl get $db_runtime/config`
#   temporary_service_configuration_path=${temporary_service_configuration_path%/*}
#   temporary_service_configuration=$(mktemp -p $temporary_service_configuration_path)
#   cat `etcdctl get $db_runtime/config` | sed -e 's/\[\[/[-----/g' -e 's/\]\]/-----]/g' > $temporary_service_configuration

#   etcdctl set $db_runtime/api_key "$(crudini --get $temporary_service_configuration misc api_key)" > /dev/null
#   etcdctl set $db_runtime/username "$(crudini --get $temporary_service_configuration misc username)" > /dev/null
#   etcdctl set $db_runtime/password "$(crudini --get $temporary_service_configuration misc password)" > /dev/null

#   # now delete the temporary configuration again
#   rm -f $temporary_service_configuration

# #  # initialise the custom configuration of the service
# #  echo create config key
# #  create_db_customconf $db_custom_config

#   # read the custom configuration of the service
#   echo read custom configuration
#   custom_ini=`read_db_customconf_values $db_custom_config`

#   # compare both configurations
#   echo compare differences between service configuration and custom configuration
#   differences=$(compare_configuration `etcdctl get $db_runtime/config` "$custom_ini")

#   # if no differences where detected we do not need to merge the configuration
#   # if differences where detected we need to merge the configuration
#   if [[ ! -z $differences ]]; then
#     echo merge custom configuration with service configuration
#     merge_configuration `etcdctl get $db_runtime/config` "$custom_ini"
#     reload=1
#   fi

#   # check if the service needs to be reloaded
#   if [ $reload -eq 1 ]; then
#     echo reload container
#     systemctl restart $container
#   fi
fi

# the runtime shouldnt be deleted when the container is stopped.
# the ip, host and api information can still be used by other containers
#if [ "$cmd" = 'stop' ]; then
#  # if stop is executed remove the running configuration of the couchpotato service
#  echo remove running configuration from etcd
#  delete_db_runtime_values $db_runtime
#fi






