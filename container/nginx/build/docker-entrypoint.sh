#!/bin/bash

# the local nginx configuration file to be replaced / parsed
CONFIG_LOCAL="/etc/nginx/nginx.conf"

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

# now check for ssl certificate
if [ "${CONFIG_GENERATE_SSL,,}" == "yes" ]; then
  # check if the key and cert environment variables are set. if not set the default values
  [ -z "$CONFIG_SSL_KEY" ] && CONFIG_SSL_KEY="/etc/pki/tls/private/nginx.key"
  [ -z "$CONFIG_SSL_CERT" ] && CONFIG_SSL_CERT="/etc/pki/tls/certs/nginx.crt"
  echo "Check for SSL certificates"
  if [ ! -f "$CONFIG_SSL_KEY" ] || [ ! -f "$CONFIG_SSL_CERT" ]; then
    echo "SSL key or certficate not found. Try to generate the certificate and key"
    # check if subj is set 
    if [ -z "$CONFIG_SSL_SUBJ" ]; then
        echo "Please set 'CONFIG_SSL_SUBJ' to generate the certificate"
    else
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $CONFIG_SSL_KEY -out $CONFIG_SSL_CERT -subj "$CONFIG_SSL_SUBJ"
    fi
  fi
fi

# now parse the nginx configuration file with j2
echo "Parse the nginx configuration file with j2"
mv -f "$CONFIG_LOCAL" "$CONFIG_LOCAL.orig"
j2 "$CONFIG_LOCAL.orig" > "$CONFIG_LOCAL"
[ $? -ne 0 ] && exit 1

# run nginx
echo "Run nginx"
/usr/sbin/nginx -c "$CONFIG_LOCAL"
