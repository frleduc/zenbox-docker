#!/bin/sh

# Fancy prompt courtesy of @soulshake.
echo 'export PS1="\[\033[0;35m\]\u@\H \[\033[0;33m\]\w\[\033[0m\]: "' >> ~/.bashrc

#apt-get -q update
apt-get -qy install git jq python-pip

pip install -U docker-compose

# Wait for docker to be up.
# If we don't do this, Docker will not be responsive during the next step.
while ! docker version
do
	sleep 1
done

# git clone our repo
git clone https://github.com/ZenikaOuest/talk-docker-insight.git /home/docker/talk-docker-insight/

# Pre-pull a bunch of images.
for I in \
	ubuntu:latest redis tomcat:7 traefik ggerbaud/hello-hostname ggerbaud/pyredis python:3.5.0-onbuild docker/whalesay
do
	docker pull $I
done
