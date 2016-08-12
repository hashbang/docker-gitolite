#!/bin/sh -e

## Generate SSH host keys
KEYDIR=/srv/ssh

# Generate missing keys
[ -f ${KEYDIR}/ssh_host_ed25519_key ] ||
    ssh-keygen -q -N '' -C '' -t ed25519     -f ${KEYDIR}/ssh_host_ed25519_key

[ -f ${KEYDIR}/ssh_host_rsa_key ] ||
    ssh-keygen -q -N '' -C '' -t rsa -b 4096 -f ${KEYDIR}/ssh_host_rsa_key

# Display checksums
ssh-keygen -l -f ${KEYDIR}/ssh_host_ed25519_key.pub
ssh-keygen -l -f ${KEYDIR}/ssh_host_rsa_key.pub


## Setup gitolite
if [ ! -e /srv/git/.gitolite ]; then
    if [ -z "${GITOLITE_ADMIN}" ]; then
	echo "Gitolite is not initialized and GITOLITE_ADMIN is not set" >&2
	exit 1
    fi

    echo "${GITOLITE_ADMIN}" > /tmp/admin.pub
    gitolite setup -pk /tmp/admin.pub
    rm /tmp/admin.pub
fi

## Run OpenSSH
exec /usr/sbin/sshd -De
