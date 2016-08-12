docker-gitolite
===============

Run gitolite3 in a docker container, without root privileges.

Build the docker image.

    sudo bootstrap-vz docker.yaml

Run the image, creating a new container.

    docker run -e GITOLITE_ADMIN="$(cat ~/.ssh/id_ed25519.pub)" --name gitolite -p 2222:2222 gitolite)

The gitolite instance is now configured and running over SSH on port 2222. To confirm:

	% ssh -p2222 git@localhost info

	hello admin, this is git@df07e0f0451f running gitolite3 3.6.1-2+deb8u1 (Debian) on git 2.1.4
	
	 R W	gitolite-admin
	 R W	testing

