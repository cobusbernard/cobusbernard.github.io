---
layout: post
title: Git checkout error for public repo
exclude_comments: false
categories: [Version Control]
tags: [ssh, https, git]
fullview: false
---

~~~bash
git clone git@github.com:cobusbernard/Scripts.git
Cloning into 'Scripts'...
Warning: Permanently added the RSA host key for IP address '192.30.252.131' to the list of known hosts.
Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
~~~

~~~bash
ls ~/ssh/
known_hosts
~~~

~~~bash
git clone https://github.com/cobusbernard/Scripts.git
Cloning into 'Scripts'...
remote: Counting objects: 9, done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 9 (delta 0), reused 0 (delta 0), pack-reused 6
Unpacking objects: 100% (9/9), done.
Checking connectivity... done.
~~~
