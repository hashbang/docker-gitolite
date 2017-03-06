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

    su -c 'git clone /srv/git/repositories/gitolite-admin.git /tmp/ga' git
    su -c 'cp /srv/git/.gitolite.rc /tmp/ga/gitolite.rc'               git
    su -c 'git -C /tmp/ga add gitolite.rc'			       git
    su -c 'git -C /tmp/ga commit -m "Moving gitolite.rc to vcs"'       git
    su -c 'cd /tmp/ga; gitolite push'                                  git
    rm -rf /tmp/ga

    if ! [ -e /srv/git/.gitolite/gitolite.rc ]; then
	echo "gitolite setup failed"
	exit 1
    fi

    su -c 'ln -sf /srv/git/.gitolite/gitolite.rc /srv/git/.gitolite.rc'
fi

## Run OpenSSH
exec /usr/sbin/sshd -De
