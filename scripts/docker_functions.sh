# queries the docker remote api
# the query is handled over the local unix socket
# the script the function uses must be run as root!
function docker_get_json {
  # remove potential set variables
  unset search
  unset data
  unset temp

  # first parameter is the search string
  search=$1

  # the search query returns an array with up to 5 fields
  # field one = status message
  # field two = content type
  # field three = query date and time
  # field four = return data size / chunk
  # field five = json array
  STATUS=0
  CONTENT=1
  DATE=2
  SIZE=3
  JSON=4

  # set the field seperator to newline
  # this will split the output of the docker array into the array
  IFS=$'\n'
  # query the docker remote api:
  # push the query string to socat which forwards it to the unix socket and sends the output to stdout
  # the sed command removes the empty line after the meta data
  # and the output is then stored into the data array
  data=($(echo -e "GET $search HTTP/1.1\r\n" | socat unix-connect:/var/run/docker.sock STDIO | sed '/^\s*$/d'))
  unset IFS
  # remove the trailing line feed from all array values
  for i in "${!data[@]}"
  do
    data[$i]=`echo ${data[$i]} | tr -d "\n\r"`
  done

  # first check if the status is OK
  if [[ "${data[STATUS]}" == "HTTP/1.1 200 OK" ]]; then
    # now check if we received a complete answer
    # or if the answer was initially "chunked"
    if [[ "${data[SIZE]}" == "Transfer-Encoding: chunked" ]]; then
      # if the answer was initially chunked we need to cleanup the
      # array a little bit. Two additional fields are added to the
      # array
      # an hex number which describes the chunk size
      # the hex number is on the fifth position (instead of the json data)
      # a trailing zero which shows the end of the chunk
      # both fields needs to be removed
      temp=("${data[@]}")
      unset data
      declare -a data
      data[0]=${temp[0]}
      data[1]=${temp[1]}
      data[2]=${temp[2]}
      data[3]=${temp[3]}
      data[4]=${temp[5]}
      unset temp

      #data=(${data[@]:0:$(($JSON))} ${data[@]:$(($JSON+1)):1})
    fi

    # now we got all necessary information from the docker api
    # for now just return the json data
    echo ${data[JSON]}
    return 0
  else
    >&2 echo "could not retrieve data from docker api - ${data[STATUS]}"
    return 1
  fi
  # revert the IFS change
}


function get_container_id {
  # this function returns the id of a container
  # it only looks for running containers.
  # and checks against the given name of the container
  # the sed expression replaces / with \/ as they are
  # escaped in the json

  # remove potential variables
  unset containter_name
  unset container_name_count
  unset containers
  unset container_count
  unset id

  container_name=$(echo $1 | sed -e 's/\//\\\//g')

  # check if a paramter is set
  if [ -z "$container_name" ]; then
    >&2 echo "please specify container name to look for"
    return 1
  fi

  # get all running containers
  containers=`docker_get_json "/containers/json?all=true"` || return 1

  # return the elements in the returned array
  container_count=`echo $containers | jshon -l`

  # now loop trough the array of containers
  for (( i=0; i<$container_count; i++ ))
  do
    # get the names of the container and compare it
    # with the search parameter
    container_name_count=`echo $containers | jshon -e $i -e Names -l`
    for (( n=0; n<$container_name_count; n++ ))
    do
      if [[ "\"\\/$container_name\"" == "`echo $containers | jshon -e $i -e Names -e $n`" ]]; then
        id=$(echo $containers | jshon -e $i -e Id | sed 's/"//g')
        break 2
      fi
    done
  done

  if [ -z "$id" ]; then
    >&2 echo "no container id found for $container_name"
    return 1
  fi

  echo $id
  return 0
}

function get_container_data_json {
  # unset potential set variables
  unset container_id
  unset container_data


  # this functions retrieves all information from a container
  # by its id (or name)
  container_id=$1

  # check if a paramter is set
  if [ -z "$container_id" ]; then
    >&2 echo "please specify container id to look for"
    return 1
  fi

  container_data=`docker_get_json "/containers/$container_id/json"` || return 1

  # check if we received container data
  if [ -z "$container_data" ]; then
    >&2 echo "could not retrieve any data for the container with id $container_id"
    return 1
  fi

  echo $container_data
  return 0
}

function get_container_value {
  # delete potential set variables
  unset container_name
  unset container_value
  unset id
  unset data
  unset searchstring
  unset value

  # this function returns the specified value for a container
  # the first parameter the function takes is the name or id of the container
  # the second paramter is the value to look for
  container_name=$1
  container_value=$2

  # check if a paramter is set
  if [ -z "$container_name" ]; then
    >&2 echo "please specify container name to look for"
    return 1
  fi
  # check if a paramter is set
  if [ -z "$container_value" ]; then
    >&2 echo "please specify container value to look for"
    return 1
  fi

  id=`get_container_id $container_name` || return 1
  data=`get_container_data_json $id` || return 1

  # read in the values
  # a value in a docker container is represented like 'NetworkSettings.IPaddress'
  # the jshon parser wants to have each value by itself separated by -e
  # '-e Networksettings -e IPAddress'. To make this happen we split the searchstring into an array
  # and create it new with the full jshon cmd
  IFS='.'
  read -a values <<< "$container_value"
  unset IFS

  searchstring='jshon -Q'
  for i in "${values[@]}"
  do
    searchstring="$searchstring -e $i"
  done

  value=$(echo $data | $searchstring)

  if [ -z "$value" ]; then
    >&2 echo "could not find the specified value $container_value in the container $container_name"
    return 1
  else
    echo $value
    return 0
  fi

}

function get_container_ip {
  # delete potential set variables
  unset containter_name
  unset container_ip

  # this function gets the ip address from a running container
  # it takes the name of the container as parameter
  container_name=$1
  # check if a paramter is set
  if [ -z "$container_name" ]; then
    >&2 echo "please specify container name to look for"
    return 1
  fi

  container_ip=$(get_container_value $container_name NetworkSettings.IPAddress | sed 's/"//g') || return 1

  if [ -z "$container_ip" ]; then
    >&2 echo "could not find an ip address for container $container_name"
    return 1
  else
    echo $container_ip
    return 0
  fi
}

function get_container_mac {
  # delete potential set variables
  unset containter_name
  unset mac

  # this function gets the ip address from a running container
  # it takes the name of the container as parameter
  container_name=$1

  # check if a paramter is set
  if [ -z "$container_name" ]; then
    >&2 echo "please specify container name to look for"
    return 1
  fi

  container_mac=$(get_container_value $container_name NetworkSettings.MacAddress | sed 's/"//g') || return 1

  if [ -z "$container_mac" ]; then
    >&2 echo "could not find a mac address for container $container_name"
    return 1
  else
    echo $container_mac
    return 0
  fi
}

function get_container_volume_path {
  # delete potential set variables
  unset containter_name
  unset container_volume
  unset volumes
  unset volume

  # this function gets the physical path of a volume exposed by the container
  # it takes two paramters. the first parameter is the name or id of the container
  # the second is the exposed volume to look for
  container_name=$1
  container_volume=$2

  # check if a paramter is set
  if [ -z "$container_name" ]; then
    >&2 echo "please specify container name to look for"
    return 1
  fi
  # check if a paramter is set
  if [ -z "$container_volume" ]; then
    >&2 echo "please specify container volume to look for"
    return 1
  fi

  # get all volumes assigned to the container
  volumes=`get_container_value $container_name Volumes` || return 1
  # check if we received any volume at all
  if [[ `echo $volumes | jshon -l` -eq 0 ]]; then
      >&2 echo "no volumes are assigned to container $container_name"
      return 1
  fi

  # now try to find the volume we are looking for
  volume=`echo $volumes | jshon -Q -e $container_volume -u`

  if [ -z "$volume" ]; then
    >&2 echo "could not find volume $container_volume in container $container_name"
    return 1
  else
    echo $volume
    return 0
  fi
}

function get_container_port {
  # delete potential set variables
  unset container_name
  unset assigned_ports
  unset port

  # this function retrieves the first exposed port of the container
  # for now we assume that the first port number of the device is the
  # port used by users and services to communicate to the system

  # this is not quite how it should be handled but hey
  # at least its a start

  # the function takes one parameter, the name or id of the container
  container_name=$1

  # check if a paramter is set
  if [ -z "$container_name" ]; then
    >&2 echo "please specify container name to look for"
    return 1
  fi

  # get all exposed ports of the container
  assigned_ports=`get_container_value $container_name NetworkSettings.Ports`
  # check if we received any ports at all
  if [[ `echo $assigned_ports | jshon -l` -eq 0 ]]; then
      >&2 echo "no ports are assigned to container $container_name"
      return 1
  fi

  # now parse the returned json array and get the hostport value of the first object in the array
  port=`echo $assigned_ports | jshon -Q -a -e 0 -e HostPort -u`

  if [ -z "$port" ]; then
    >&2 echo "could not get the first port of the container"
    return 1
  else
    echo $port | cut -d" " -f1
    return 0
  fi
}


