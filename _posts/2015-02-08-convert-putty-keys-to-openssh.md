---
layout: post
title: Converting Putty keys to OpenSSH
exclude_comments: false
categories: [General]
tags: [ssh, putty]
fullview: false
---

I was playing with [Docker](http://docker.com) yesterday and needed to convert a key that I had been using in Windows with Putty for a while. First attempt with puttygen didn't work at all, then I found this [Stack Overflow post](http://superuser.com/questions/232362/how-to-convert-ppk-key-to-openssh-key-under-linux), copying the details here so I know where to find it next time :)

To install the required tools, use

~~~ bash
Ubuntu: sudo apt-get install putty-tools
OSX: brew install putty
~~~

After the requried tools have been installed, use the following 2 commands to extract the private and public portion of the key:

~~~ bash
puttygen id_dsa.ppk -O private-openssh -o id_dsa
puttygen id_dsa.ppk -O public-openssh -o id_dsa.pub
~~~
