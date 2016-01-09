---
layout: post
title: Git checkout error for public repo
exclude_comments: false
tagline: How to avoid authentication issues on GitHub when using SSH as the protocol.
image:
categories: [Version Control]
tags: [ssh, https, git]
fullview: false
---
One of those *djissis duh* moments - trying to check out a public git repo, but failing due to authentication ...

~~~
git clone git@github.com:cobusbernard/Scripts.git
Cloning into 'Scripts'...
Warning: Permanently added the RSA host key for IP address '192.30.252.131' to the list of known hosts.
Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
~~~

So I checked my ssh setup / keys, but nothing in there looks dodgy:

~~~
ls ~/ssh/
known_hosts
~~~

So it ended up being ssh vs https cloning. SSH checkout is always authenticated.

~~~
git clone https://github.com/cobusbernard/Scripts.git
Cloning into 'Scripts'...
remote: Counting objects: 9, done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 9 (delta 0), reused 0 (delta 0), pack-reused 6
Unpacking objects: 100% (9/9), done.
Checking connectivity... done.
~~~
