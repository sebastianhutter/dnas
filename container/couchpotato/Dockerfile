FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD build /tmp/build
WORKDIR /tmp/build
RUN ansible-playbook couchpotato.yml -c local -t setup
WORKDIR /
RUN rm -rf /tmp/build

EXPOSE 5050

# become rssdler user
USER container
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["-c couchpotato"]

