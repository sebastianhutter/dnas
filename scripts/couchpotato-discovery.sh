#!/bin/bash

#
# this script is used by the couchpotato discovery service
#
# it writes the necessary information for the couchpotato service
# to the etcd database

# import basic bash functions to retrieve information from docker containers
source ./docker_functions.sh

# container name
container=couchpotato

# basic variables for the etcd service
db_root=/services/couchpotato
db_runtime=$db_root/run
db_custom_config=$db_root/config


# fill in basic container information into etcd
etcdctl set $db_runtime/ip `get_container_ip $container`
etcdctl set $db_runtime/mac `get_container_mac $container`
etcdctl set $db_runtime/port `get_container_port $container`
etcdctl set $db_runtime/workingdir `get_container_volume_path $container /home/couchpotato/.couchpotato`
etcdctl set $db_runtime/config `get_container_volume_path $container /home/couchpotato/.couchpotato`/settings.conf

# now get the couchpotato api key, username and password and store them in the runtime part
# those values can and will be used by other containers to autoconfigure

