---
title: Linux SSH rate limiting
description: How to limit the number of connections using IpTables.
date: 2013-01-28
categories: [Linux]
tags: [linux, security, ssh]
aliases:
  - /linux/2013/01/28/ssh-rate-limit
  - /linux/2013/01/28/ssh-rate-limit.html
---
Everyone who has an SSH port open to the world knows the amount of brute force attempts you will get. It doesn’t matter if you only accept keys, the script kiddies will still try. Easiest fix for this is rate limiting: you can only attempt to login 3 times per 10 minutes. This does not include successful logins, only failed ones. To do this, use the following IPTables commands:

```bash
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name  SSH --rsource
sudo iptables -A INPUT -m recent --update --seconds 600 --hitcount 4 --rttl --name SSH  --rsource -j DROP
sudo iptables-save > /etc/iptables_rules
```

Add the following to /etc/rc.local before the ‘exit':

```bash
/sbin/iptables-restore < /etc/iptables_rules
```

This will add the rules back if you reboot.
