FROM ansible/centos7-ansible:stable

# export the volumes for the rssdler configuration
# and the download directory
#VOLUME ['/var/lib/rssdler/download']
#VOLUME ['/var/lib/rssdler/workingdir']
#VOLUME ['/var/lib/rssdler/logs']

# run the ansible playbook to setup the rssdler service
ADD ansible /tmp/ansible
WORKDIR /tmp/ansible
RUN ansible-playbook rssdler.yml -c local
RUN rm -rf /tmp/ansible

# become rssdler user
USER rssdler
# run the rssdler script
ENTRYPOINT ["/usr/bin/rssdler"]
# if no parameters are given show the help
CMD ["--help"]