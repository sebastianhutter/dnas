# nginx docker image

this nginx docker image uses a compiled nginx source with the nginx-auth-ldap module from
https://github.com/kvspb/nginx-auth-ldap.

## usage

you can start the nginx container by specifing a nginx configuration file and/or the
www-root volume as described in the original nginx docker image: https://hub.docker.com/_/nginx

### download the nginx configuration from http / https
In addition the containers entrypoint script is able to directly download a nginx configuration via http/https.
To use this behaviour the script checks for the following environment variables.
CONFIG_URL=<url to configuration file>
CONFIG_USERNAME=<username for git authentication or http simple auth>
CONFIG_PASSWORD=<password for git authentication or http simple auth>

### using environment variables in the configuration file
before the nginx service starts the configuration file is parsed with j2cli - https://github.com/kolypto/j2cli.
This enables you to use additional environment variables in the nginx configuration and replace them on the fly

### ssl config 
If the environment variable CONFIG_GENERATE_SSL is set to 'yes' the entry point script will check for an exisitng private 
key and certificate in /etc/pki/tls/private/nginx.key and /etc/pki/tls/certs/nginx.crt. If the files dont exist they will
be created automatically.

If the environment variable is either missing or set to anything else then 'yes' (case-insensitive) no ssl certificates will be 
checked or generated

You can change the name of the key and cert file by setting the environment variables CONFIG_SSL_KEY and CONFIG_SSL_CERT.

To generate the certificate to set the environment variable CONFIG_SSL_SUBJ which will be used by openssl to generate the certificate
without prompt
