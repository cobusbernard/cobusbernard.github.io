---
layout: post
title: Setting up a Timemachine server using Mesos/Marathon
exclude_comments: false
tagline: Running netatalk in a container for home OSX backups
image:
categories: [Docker]
tags: [docker, mesos, marathon, apply, osx, home]
fullview: false
---

I am currently unable to upgrade to the latest version of [Slack](https://slackhq.com) due to [this bug](https://github.com/electron/electron/issues/7840). That combined with my user profile confusion (originally I set up using a US account, then changed to an South African one) that causes requests to update to versions of iPhoto which aren't available in my region made me decide that it is time for a reformat.  

To create a full backup to my raid'ed server, I need to set up [netatalk](http://netatalk.sourceforge.net/). I started reading [this post](https://samuelhewitt.com/blog/2015-09-12-debian-linux-server-mac-os-time-machine-backups-how-to) but decided that I didn't want to polute my server with all of those installs. Seeing that I already have [Mesos](http://mesos.apache.org/) and [Marathon](https://mesosphere.github.io/marathon/) running, I went the docker route. I found [this repo](https://github.com/cptactionhank/docker-netatalk) and proceeded to create the following Marathon config:

~~~
{
  "id": "netatalk",
  "instances": 1,
  "cpus": 0.2,
  "mem": 256.0,
  "constraints": [["hostname", "CLUSTER", "myhost.mydoamin.com"]],
  "container": {
    "docker": {
      "image": "cptactionhank/netatalk:latest",
      "network": "HOST",
      "portMappings":
      [
          {
              "containerPort": 548,
              "protocol": "tcp"
          }
      ]
    },
    "type": "DOCKER",
    "volumes": [
      {
        "hostPath": "/data/media",
        "containerPath": "/media/share",
        "mode": "RW"
      },
      {
        "hostPath": "/data/timemachine",
        "containerPath": "/media/timemachine",
        "mode": "RW"
      }
    ]
  },
  "env": {
    "AVAHI": "1",
    "AFP_USER": "timemachine",
    "AFP_PASSWORD": "super_secret",
    "AFP_UID": "1012",
    "AFP_GID": "1007"
  },
  "healthChecks": [
    {
      "gracePeriodSeconds": 60,
      "intervalSeconds": 30,
      "maxConsecutiveFailures": 0,
      "port": 548,
      "protocol": "TCP"
    }
  ]
}
~~~

**The important parts are:**

Limiting where the container may run, in my case, I only want it on my server with the raid array:

~~~
"constraints": [["hostname", "CLUSTER", "myhost.mydoamin.com"]]
~~~

Netatalk runs on port `tcp/548`:

~~~
"containerPort": 548
~~~

If you want to use service discovery, you need to have the container run on the host network stack:

~~~
"network": "HOST"
~~~

You can also use netatalk to share media easily, so I mounted my media folder to share as well:

~~~
"hostPath": "/data/media",
"containerPath": "/media/share",
"mode": "RW"
~~~

The folder that timemachine will use to back up:

~~~
"hostPath": "/data/timemachine",
"containerPath": "/media/timemachine",
"mode": "RW"
~~~

The environment variables for the container:

~~~
"env": {
  "AVAHI": "1",
  "AFP_USER": "timemachine",
  "AFP_PASSWORD": "super_secret",
  "AFP_UID": "1012",
  "AFP_GID": "1007"
},
~~~

Service discovery is set with `AVAHI=1` and the other values are for credentials for timemachine. You will need to create a user on the server and get the userid and groupid for it, i.e.:

~~~
sudo adduser --home /mnt/data/timemachine timemachine
sudo chown -R timemachine:timemachine /mnt/data/timemachine
~~~

To get the userid and groupid to use, run the following:

~~~
sudo -H -u timemachine bash -c 'echo "I am $(id -un), with uid $(id -u) and gid $(id -g)"'
~~~

And that is all folks, it takes 5 minutes to set up a timemachine server using Docker, Mesos and Marathon. After the container has started up, head over to timemachine and you should see it listed when you click on the `Select disk...` button. Now I just need to add the user creation to my Chef recipes so I don't forget about it when I recreate the node...
