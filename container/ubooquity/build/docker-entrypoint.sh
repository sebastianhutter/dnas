#!/bin/bash

# the local nginx configuration file to be replaced / parsed
CONFIG_LOCAL="/ubooquity/preferences.xml"

# first check if the download url is set. if so try to download the file via curl
if [ -z "$CONFIG_URL" ]; then 
  echo "No config url set. Will use local configuration file"
else
  echo "Config url is set. Download the configuration file"
  # now try to download the configuration file
  if [ -z "$CONFIG_USERNAME" ] || [ -z "$CONFIG_PASSWORD" ]; then
    # if no usename and password is specified
    curl "$CONFIG_URL" -o "$CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  else
    curl --user $CONFIG_USERNAME:$CONFIG_PASSWORD "$CONFIG_URL" -o "$CONFIG_LOCAL"
    [ $? -ne 0 ] && exit 1
  fi
fi

# now parse the nginx configuration file with j2
echo "Parse the configuration file with j2"
mv "$CONFIG_LOCAL" "$CONFIG_LOCAL.orig"
j2 "$CONFIG_LOCAL.orig" > "$CONFIG_LOCAL"
[ $? -ne 0 ] && exit 1

# run ubooquity
echo "Run ubooquity"
java -jar /ubooquity/Ubooquity.jar -webadmin -headless -workdir /ubooquity