---
title: NTP on AWS
description: How to ensure that NTP works on a private subnet in AWS.
date: 2015-12-16
categories: [aws]
tags: [linux, aws, ntp]
aliases:
  - /aws/2015/12/16/NTP-on-AWS
  - /aws/2015/12/16/NTP-on-AWS.html
---

Ran into an issue where a Linux instance running on [AWS](http://aws.amazon.com) in a private subnet was not updating the system time via [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol). First check was for the config file, but it had a list of servers, both inside and 1 outside AWS:

```bash
server 0.amazon.pool.ntp.org
server 0.us.pool.ntp.org
server 1.amazon.pool.ntp.org
server 2.amazon.pool.ntp.org
```

From this post (I would like to link to it, but it has been 8.5 years since I wrote this, and only found the missing link today on 2024/05/29) I tried both `ntpdate` and `ntpdate-debian` with the following results:

```bash
$ ntpdate
16 Dec 22:24:14 ntpdate[32112]: no servers can be used, exiting

$ ntpdate-debian
16 Dec 22:24:56 ntpdate[32117]: no servers can be used, exiting
```

The instance did have access to a NAT box to allow access outside of the VPC and `ntpq -p` returned the following:

```bash
$ ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 ranger.innolan. .INIT.          16 u    -   64    0    0.000    0.000   0.000
 4.53.160.75     .INIT.          16 u    -   64    0    0.000    0.000   0.000
 origin.towfowi. .INIT.          16 u    -   64    0    0.000    0.000   0.000
 ntp.your.org    .INIT.          16 u    -   64    0    0.000    0.000   0.000
```

Turns out that you need to explicitly allow `udp/123` on the NAT instance's Security Group. Once I added the rule, everything started working:

```bash
$ ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 216.152.240.220 216.218.254.202  2 u    1   64    1   37.486   11.927   0.138
 ranger.innolan. 90.184.222.115   3 u    2   64    1   73.323    9.543   0.025
 srcf-ntp.stanfo .shm0.           1 u    1   64    1   25.009   12.412   0.019
 grom.polpo.org  127.67.113.92    2 u    2   64    1   22.254   13.909   0.000
```
