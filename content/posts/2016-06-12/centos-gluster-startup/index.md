---
title: Getting Glusterd to start at boot on Centos
description: Every time the server reboots, glusterd doesn't start.
date: 2016-06-12
categories: [Linux]
tags: [centos, glusterfs, linux]
aliases:
  - /linux/2016/06/12/Centos_Gluster_Startup
---

I've been working on a pair of Centos servers using [GluserFS](https://www.gluster.org/) for a volume that is shared by various other servers. Each time the server reboots, I had to log in and manually start the service. Turns out this is due to the networking no yet being started when the glusterd service starts. I found [this post](http://unix.stackexchange.com/questions/165270/centos-7-boots-too-fast-and-network-is-not-ready-when-executing-cron-scripts) with the solution:

* Execute `systemctl enable NetworkManager-wait-online`
* Add the following to `/lib/systemd/system/crond.service` under `[Unit]`:

```bash
Requires=network.target
After=syslog.target auditd.service systemd-user-sessions.service time-sync.target network.target mysqld.service
```

This will allow glusterd to be started after the network has come up.
