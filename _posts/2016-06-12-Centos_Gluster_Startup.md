---
layout: post
title: Getting Glusterd to start at boot on Centos
exclude_comments: false
tagline: Everytime the server reboot, glusterd doesn't start.
image:
categories: [Linux]
tags: [centos, glusterfs]
fullview: false
---

I've been working on a pair of Centos servers using [GluserFS](https://www.gluster.org/) for a volume that is shared by various other servers. Each time the server reboots, I had to log in and manually start the service. Turns out this is due to the networking having started when the gluster service is. I found [this post](http://unix.stackexchange.com/questions/165270/centos-7-boots-too-fast-and-network-is-not-ready-when-executing-cron-scripts) with the solution:
* Execute `systemctl enable NetworkManager-wait-online`
* Add the following to `/lib/systemd/system/crond.service` under `[Unit]`:
~~~
Requires=network.target
After=syslog.target auditd.service systemd-user-sessions.service time-sync.target network.target mysqld.service
~~~

This will allow glusterd to be started after the network has come up.
