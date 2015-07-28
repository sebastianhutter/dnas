#
# the library containers sole purpose is to server up a shared directory for
# the different services to access
# the volume will be used to store the different plex libraries
#

FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD build /tmp/build
WORKDIR /tmp/build
RUN ansible-playbook library.yml -c local
WORKDIR /
RUN rm -rf /tmp/build

VOLUME /Library

# become rssdler user
USER library
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["library"]

