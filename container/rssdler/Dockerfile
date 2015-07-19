FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD ansible /tmp/ansible
WORKDIR /tmp/ansible
RUN ansible-playbook rssdler.yml -c local

RUN rm -rf /tmp/ansible

# run the rssdler script
ENTRYPOINT ["/usr/bin/rssdler"]
CMD ["--help"]