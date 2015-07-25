FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD ansible /tmp/ansible
WORKDIR /tmp/ansible
RUN ansible-playbook rssdler.yml -c local
RUN rm -rf /tmp/ansible

# become rssdler user
USER rssdler
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
# if no parameters are given show the help
CMD ["rssdler --help"]