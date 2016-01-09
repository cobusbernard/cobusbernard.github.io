---
layout: post
title: Replacing mdadm drive
exclude_comments: false
tagline: How to identify and replace a failed drive in mdadm.
image:
categories: [Linux]
tags: [linux, mdadm]
fullview: false
---
*Update 2016-01-09*: In the previous version, I never added the command for creating the array and since I needed it for a new server. When the array starts rebuilding, it *will* look like there is a failed drive: this is normal. When it builds from scratch, it is actually doing the rebuild process and will indicate a failed drive until the array is rebuilt.

So after all that, you should be notified when something goes wrong and be able to correct it before loosing all your data.
