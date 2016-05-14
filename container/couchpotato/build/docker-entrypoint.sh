#!/bin/bash

# the local configuration file to be replaced / parsed
COUCHPOTATO_CONFIG_LOCAL="/CouchPotatoServer/settings.conf"

# sabnzbd: check for configuration download
if [ -z "$COUCHPOTATO_CONFIG_URL" ]; then 
  echo "sabnzbd: No config url set. Will use local configuration file"
else
  echo "sabnzbd: Config url is set. Download the configuration file"
  # now try to download the configuration file
  if [ -z "$COUCHPOTATO_CONFIG_USERNAME" ] || [ -z "$COUCHPOTATO_CONFIG_PASSWORD" ]; then
    # if no usename and password is specified
    curl "$COUCHPOTATO_CONFIG_URL" -o "$COUCHPOTATO_CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  else
    curl --user $COUCHPOTATO_CONFIG_USERNAME:COUCHPOTATO_CONFIG_PASSWORD "$COUCHPOTATO_CONFIG_URL" -o "$COUCHPOTATO_CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  fi
fi

# now parse the configuration files
echo "Parse the configuration file with j2"
mv "$COUCHPOTATO_CONFIG_LOCAL" "$COUCHPOTATO_CONFIG_LOCAL.orig"
j2 "$COUCHPOTATO_CONFIG_LOCAL.orig" > "$COUCHPOTATO_CONFIG_LOCAL"
[ $? -ne 0 ] && exit 1

# run couchpotato
echo "Run couchpotato"
python /CouchPotatoServer/CouchPotato.py --console_log --data_dir /CouchPotatoServer/
