function set_etcd_directory {
  # this function creates a directory in the the etcd service

  # the function takes one parameter
  # 1 = the full path to the directory to create

  # delete potentially set variables
  unset directory

  # check if a paramter is set
  directory="$1"
  if [ -z "$directory" ]; then
    >&2 echo "please specify the directory to create"
    return 1
  fi

  # now create the directory with etcdctl
  etcdctl mkdir "$directory" > /dev/null 2>&1

  # if the directory already exists the command will return the
  # error code 4
  # if the directory was created successfully it will return the
  # error code 0

  if [ "$?" -eq 0 -o "$?" -eq 4 ]; then
    return 0
  else
    >&2 echo "could not create the directory $directory in etcd"
    return 1
  fi

}

function set_etcd_key {
  # this function sets a key in etcd
  # the function overwrites any existing keys without notice

  # the function takes up to two parameters
  # 1 = the key to set
  # 2 = the value to set
  # if no value is set an empty value "" is set for the key

  # delete poptentially set variables
  unset key
  unset value

  # check if a paramter is set
  key="$1"
  value="$2"
  if [ -z "$key" ]; then
    >&2 echo "please specify the key to create"
    return 1
  fi

  # now create the key with the value
  etcdctl set "$key" "$value" > /dev/null 2>&1

  if [ "$?" -eq 0 ]; then
    return 0
  else
    >&2 echo "could not create the key $key in etcd"
    return 1
  fi
}

function get_etcd_key {
  # this function looks up and returns a value of the specified key

  # the function takes one paramter
  # 1 = the key to lookup

  # delete potentially set variables
  unset key
  unset value

  key="$1"
  if [ -z "$key" ]; then
    >&2 echo "please specify the key to lookup"
    return 1
  fi

  # now lookup the key in etcd
  value="`etcdctl get "$key" 2> /dev/null`"

  if [ "$?" -eq 0 ]; then
    echo "$value"
    return 0
  else
    >&2 echo "could not lookup the key $key in etcd"
    return 1
  fi

  echo

}

function copy_etcd_key {
  # this function copies a key with its value to a different directory in etcd
  # the function can either overwrite (default) the value at the key destination
  # or it can append or prepend the values from the source
  # the function overwrites any existing keys without notice

  # the function takes four parameters
  # 1 = source key
  # 2 = destination key
  # 3 = action - overwrite, append, prepend
  # 4 = if append or prepend is used as action the fourth parameter specifies
  #     the field seperater between old and copied value (empty by default)
  #
  # Attention: the function also overwrites the destination if the source value is empty!

  # delete potentially set variables
  unset source_key
  unset destination_key
  unset action
  unset separator
  unset source_value
  unset destination_value

  # check if the parameters are set
  source_key="$1"
  if [ -z "$source_key" ]; then
    >&2 echo "please specify the source key to copy"
    return 1
  fi

  destination_key="$2"
  if [ -z "$destination_key" ]; then
    >&2 echo "please specify the destination to copy too"
    return 1
  fi

  # set the action - if not given set it to default
  action="$3"
  if [ -z "$action" ]; then
    action="overwrite"
  fi

  # set the field separator
  separator="$4"

  # get the source value from the source key
  # if the source key cant be found abort the function
  source_value=`get_etcd_key $source_key` || return 1

  # get the destination value from the destination key
  # if the destination key cant be found proceed with the function
  destination_value=`get_etcd_key $destination_key 2>/dev/null`

  # depending on the action either just overwrite the destinatinon,
  # or append or prepend the source value
  case "$action" in
    'overwrite')
      destination_value="$source_value"
      ;;
    'append')
      destination_value="$destination_value$separator$source_value"
      ;;
    'prepend')
      destination_value="$source_value$separator$destination_value"
      ;;
    *)
      >&2 echo "unknown action for copy - use overwrite, append or prepend"
      return 1
      ;;
  esac

  # now set the the key
  set_etcd_key "$destination_key" "$destination_value" || return 1
  return 0
}

