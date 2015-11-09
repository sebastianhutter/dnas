#!/bin/bash

# if a key file does not exist re run the key generation
while true; do
  if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    /usr/bin/ssh-keygen -A
    break
  fi

  if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
    /usr/bin/ssh-keygen -A
    break
  fi

  if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    /usr/bin/ssh-keygen -A
    break
  fi
  break
done


# run sshd
/sbin/sshd -D