FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD build /tmp/build
WORKDIR /tmp/build
RUN ansible-playbook backuppc.yml -c local -t setup
WORKDIR /
RUN rm -rf /tmp/build

EXPOSE 8433
EXPOSE 2222

# become rssdler user
USER container
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["-c backuppc"]

