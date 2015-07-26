FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD build /tmp/build
WORKDIR /tmp/build
RUN ansible-playbook rssdler.yml -c local
WORKDIR /
RUN rm -rf /tmp/build

# become rssdler user
USER rssdler
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
# if no parameters are given show the help
CMD ["rssdler", "--help"]