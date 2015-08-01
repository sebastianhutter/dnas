
function set_db_runtime_container_values {
  # this function sets the runtime information for the container
  # the runtime information is the ip, mac and port of the container

  # it takes two parameters
  # 1 = the container name or ip
  # 2 = the path to the runtime config in etcd

  # check if a paramter is set
  container=$1
  if [ -z "$container" ]; then
    >&2 echo "please specify container name to look for"
    return 1
  fi

  db_runtime=$2
  if [ -z "$db_runtime" ]; then
    >&2 echo "please specify the etcd path of the runtime config"
   return 1
  fi

  # fill in basic container information into etcd
  etcdctl set $db_runtime/ip `get_container_ip $container` > /dev/null
  etcdctl set $db_runtime/mac `get_container_mac $container` > /dev/null
  etcdctl set $db_runtime/port `get_container_port $container` > /dev/null
  return 0
}

function delete_db_runtime_values {
  # remove the run time part in the etcd database

  # the function takes one parameter
  # 1 = the path to the runtime config in etcd

  db_runtime=$1
  if [ -z "$db_runtime" ]; then
    >&2 echo "please specify the etcd path of the runtime config"
   return 1
  fi

  etcdctl rm --recursive $db_runtime
  return 0
}

function create_db_customconf {
  # this function creates the custom configuration path
  # if the path exists nothing will be created.

  # the function takes one parameter
  # 1 = the path to the custom config in etcd

  db_custom_config=$1
  if [ -z "$db_custom_config" ]; then
   >&2 echo "please specify the etcd path for the custom config"
   return 1
  fi

  etcdctl mkdir $db_custom_config > /dev/null  2>&1
  return 0
}

function copy_service_configuration {
  # this function copies a value from one key in an etcd service configuratin
  # to another key
  # the key is only copied if the value of src is not empty

  # the function takes four parameters
  # 1 = source to copy from
  # 2 = destination to copy to
  # 3 = can be either "append" or "prepend". if set it will add the src value either at
  #     the beginning or end of the existing value instead of replacing it
  # 4 = if the third parameter is used the symbol will be used as field separator


  # check if a paramter is set
  source_key=$1
  if [ -z "$source_key" ]; then
    >&2echo "please specify a source key"
    return 1
  fi

  # check if a paramter is set
  dest_key=$2
  if [ -z "$dest_key" ]; then
    >&2echo "please specify a destination key"
    return 1
  fi

  # get the source value and check if it exists
  source_value=`etcdctl get $source_key 2> /dev/null`
  if [ -z "$source_value" ]; then
    >&2echo "could not find a value at $source_key"
    return 1
  fi

  # get the destination value
  destination_value=`etcdctl get $dest_key 2> /dev/null`

  # check if the third parameter is set
  if [ ! -z $3 ]; then
    # if parameter is append then add the value to the end of the existing key
    if [ "$3" = 'append' ]; then
      destination_value=$destination_value$4$source_value
    else
      # if parameter is prepend add the value to the beginning of the existing key
      if [ "$3" = 'prepend' ]; then
        destination_value=$source_value$4$destination_value
      else
        >&2 echo "please use 'append' or 'prepend' as parameter"
        return 1
      fi
    fi
  else
    # if the third parameter is not set overwrite the destination with the source value
    destination_value=$source_value
  fi

  etcdctl set $dest_key $destination_value > /dev/null
  return 0
}


function read_db_customconf_values {
  # the etcd database also holds some custom configuration values which allows overwriting
  # the configuration file of the service without root access to the docker data contaienr

  # the configuration file of the different services (couchpotato, sabnzbd, nzbtomedia, rssdler, sickbeard)
  # are all ini files. a ini file is setup in sections [xyz], parameters and values.
  # this setup can be build into etcd pretty easily
  # $db_custom_config_db/section/parameter value
  # which translates to the ini format:
  # [section]
  # parameter = value

  # this function reads the custom configuration and converts it to an ini file
  # which can be used to merge into the current configuration of the service

  # the function takes one parameter
  # 1 = the path to the custom config in etcd

  # check if a paramter is set
  db_custom_config=$1
  if [ -z "$db_custom_config" ]; then
    >&2 echo "please specify the etcd path for the custom config"
    return 1
  fi

  ini=''
  for section in `etcdctl ls $db_custom_config`
  do
    # extract the section name from the full etcd path
    ini=$ini"[${section:${#db_custom_config}+1}]\n"
    for parameter in `etcdctl ls $section`
    do
      ini=$ini"${parameter:${#section}+1} = `etcdctl get $parameter`\n"
    done
    ini=$ini"\n"
  done
  echo $ini
  return 0
}

function compare_configuration {
  # this function compares the custom configuration with the configuration file used by the service
  # the ini files are convered to lines with crudini and then compared against each other with comm
  # a merge is necessary if one of the following conditions is met
  # 1. a line is added to the custom configuration which does not exist in the configuration used by the service
  # 2. a value of a parameter is different in the custom configuration then in the configuration used by the service

  # the script takes two parameters
  # 1 = the path to the service configuration
  # 2 = the custom configruation returned by the function read_db_customconf_values

  # check if a paramter is set

  service_configuration=$1
  if [ -z "$service_configuration" ]; then
    >&2 echo "please specify the path to the service configuration file"
    return 1
  fi

  # check if a paramter is set
  custom_configuration=$2
  if [ -z "$custom_configuration" ]; then
    >&2 echo "no custom configuration given, either custom config is empty or was not added als parameter"
    return 1
  fi

  differences=$(comm -13 <(crudini --get --format=lines $service_configuration | sort) <(echo -e $custom_configuration | crudini --get --format=lines -| sort))
  echo $differences
  return 0
}

function merge_configuration {
  # this function merges the service configuration with the custom configuration from etcd
  # before the merge is done a copy of the service configuration is created

  # the function takes two parameters:
  # 1 = the path to the service configuration
  # 2 = the custom configruation returned by the function read_db_customconf_values

  # check if a paramter is set
  service_configuration=$1
  if [ -z "$service_configuration" ]; then
    >&2 echo "please specify the path to the service configuration file"
    return 1
  fi

  # check if a paramter is set
  custom_configuration=$2
  if [ -z "$custom_configuration" ]; then
    >&2 echo "please specify the custom configuration in ini format"
    return 1
  fi

  # first create a backup of the service configuration file
  # the backup file name consists of the current date + seconds since 1970 and a 4 letter random string
  # to circumvent an filename overlap
  backup="$service_configuration-`date +%Y%m%d-%s`-`cat /dev/urandom | tr -dc 'a-zA-Z' | head -c 4`"
  cp $service_configuration $backup

  # now merge the custom configuration file into the service configuration
  # crudini --merge $service_configuration <(echo -e $custom_configuration)
  crudini --merge $service_configuration < <(echo -e $custom_configuration)
  if [ "$?" -eq "0" ]; then
    return 0
  else
    >&2 echo "the merge returned an error"
    return 1
  fi
}

