---
layout: post
title: Personal VPN - OpenVPN in Docker on DigitalOcean
exclude_comments: false
categories: [General]
tags: [linux, openvpn, vpn, docker]
fullview: false
---

I was playing around one some [random](http://netflix.com) site today, when I received the message *This content is not available in your country yet*. As a South African, we run into this a lot as our online presence it not that great and a lot of international companies do not feel that it is financially viable to run their services here. So I decided it is time that I get a VPN service going to avoid this issue. Decided to use a [Digital Ocean](https://www.digitalocean.com/) Droplet for this task. The smallest one has 512MB Ram, 20GB SSD, 1 core and 1TB of transfer - this will be plenty to get the VPN up and possible some other services. Signup was very quick and I was very happy to see that they support 2 factor auth via [Google Authenticator](https://itunes.apple.com/za/app/google-authenticator/id388497605?mt=8).

I found this [easy guide](https://www.digitalocean.com/community/tutorials/how-to-run-openvpn-in-a-docker-container-on-ubuntu-14-04) on how to set up the VPN using [Docker](http://docker.io) - blindly followed it and took about 5 mins to get everything going. This is a lot quicker than back in the day where I would first set up a VM with Ubuntu, update it and then do all the installation / configuration of [OpenVPN](https://openvpn.net/) manually. Here are the commands in order for quick copy & paste - still need  to create or find an [Ansible](http://www.ansible.com/home) playbook for this to make it even easier. The commands should be run as a normal user - it will *sudo* where needed.

~~~bash
DOMAIN=vpn.yourdomain.com
CURRENT_USER=$(whoami)
OVPN_DATA="ovpn-data"
DOCKER_CONFIG=/etc/init/docker-openvpn.conf

curl https://get.docker.io/gpg | sudo apt-key add -
echo deb http://get.docker.io/ubuntu docker main | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update && sudo apt-get install -y lxc-docker
sudo usermod -aG docker $CURRENT_USER
su - $CURRENT_USER
docker run --name $OVPN_DATA -v /etc/openvpn busybox
docker run --volumes-from $OVPN_DATA --rm kylemanna/openvpn ovpn_genconfig -u udp://$DOMAIN:1194
docker run --volumes-from $OVPN_DATA --rm -it kylemanna/openvpn ovpn_initpki

sudo touch $DOCKER_CONFIG
sudo printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
'description "Docker container for OpenVPN server"' \
'start on filesystem and started docker' \
'stop on runlevel [!2345]' \
'respawn' \
'script' \
'  exec docker run --volumes-from ovpn-data --rm -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn' \
'end script' >> $DOCKER_CONFIG

sudo start docker-openvpn
~~~~

At this point, the Docker container will be created, configured and running via an upstart script. To add a user, use the following 2 commands - first one will create the user and the second will output the config file to the host VM to allow copying it to the client.

~~~bah
docker run --volumes-from $OVPN_DATA --rm -it kylemanna/openvpn easyrsa build-client-full CLIENTNAME nopass
docker run --volumes-from $OVPN_DATA --rm kylemanna/openvpn ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn
~~~

The client isntallation is trivial and the guide does a great job covering all the major operating systems.
