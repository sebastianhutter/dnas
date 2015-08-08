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
  unset reload_loop
  unset reload_wait
  unset ip
  unset mac
  unset port
  unset loop_counter
  unset workingdir
  unset configfile
  unset custom_ini
  unset original_ini
  unset merged_ini

  reload=0
  reload_loop=3
  reload_wait=3
  loop_counter=0
  while [ "$loop_counter" -lt "$reload_loop" ]
  do
    loop_counter=$((loop_counter+1))
    echo configuration loop $loop_counter of $reload_loop
    echo wait $reload_wait seconds before starting configuration
    sleep $reload_wait

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
    set_etcd_key "$db_runtime/workingdir" "`get_container_volume_path $container /home/couchpotato/.couchpotato`"
    workingdir=`get_etcd_key $db_runtime/workingdir`
    if [ -z $workingdir ]; then
      >&2 echo "could not find the working dir of the sabnzbd service. the configuration file can not be changed"
    else
      # for now we can guarantee that the configuration file can only exist
      # if we can find the specified workingdir.
      echo setting $container config file
      configfile="$workingdir/settings.conf"
      set_etcd_key "$db_runtime/config" "$configfile"
      echo container config file is \'$configfile\'

      # now read the original ini file.
      echo parse config file \'$configfile\'
      original_ini=`read_ini_configuration_file $configfile`

      # set some additiona values which will be needed by other services
      # if the values cant be found in the ini file the values will be set empty
      echo set the couchpotato api key, username and password
      echo set \'$db_runtime/api_key\'
      set_etcd_key $db_runtime/api_key "`crudini --get <(echo -e $original_ini) core api_key 2>/dev/null || >&2 echo couldnt find api key in config`"
      echo set \'$db_runtime/username\'
      set_etcd_key $db_runtime/username "`crudini --get <(echo -e $original_ini) core username 2>/dev/null || >&2 echo couldnt find api key in config`"
      echo set \'$db_runtime/password\'
      set_etcd_key $db_runtime/password "`crudini --get <(echo -e $original_ini) core password 2>/dev/null || >&2 echo couldnt find api key in config`"

      echo set sabnzbd information for nzbtomedia configuration file
      copy_etcd_key "$sabnzbd_ip" "$db_custom_config/[sabnzbd]/host"
      copy_etcd_key "$sabnzbd_port" "$db_custom_config/[sabnzbd]/host" "append" ":"
      copy_etcd_key "$sabnzbd_apikey" "$db_custom_config/[sabnzbd]/api_key"

      echo parse custom configuration in etcd
      custom_ini=`read_ini_configuration_database $db_custom_config`


      # now compare the ini file with the custom configuration from the db
      # if differences are detected (from the custom configuration in the db to the ini file)
      # the differences will be merged into the configuration file
      echo compare ini configuration.
      compare_ini_configuration "$original_ini" "$custom_ini" || {
        echo differences found. merge custom configuration to configuration file
        merged_ini=`merge_ini_configuration "$original_ini" "$custom_ini"`

        echo writing configuration file
        write_ini_configuration "$configfile" "$merged_ini" || {
          echo could not write to config file.
        }

        # set the container to restart when the configuration loop
        # has finished
        reload=1
        continue
      }
      echo no differences found
    fi
  done

  # if the container needs to be reloaded execute a systemctl restart
  if [ $reload -eq 1 ]; then
    echo reload container $container
    systemctl restart $container
  fi
fi