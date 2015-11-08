FROM ansible/centos7-ansible:stable

# run the ansible playbook to setup the rssdler service
ADD build /tmp/build
WORKDIR /tmp/build
RUN ansible-playbook openvpnas.yml -c local -t setup
WORKDIR /
RUN rm -rf /tmp/build

EXPOSE 943
EXPOSE 1194
EXPOSE 1194/UDP

VOLUME "/usr/local/openvpn_as/etc"

# become rssdler user
USER container
# run the rssdler script
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["-c openvpnas"]
