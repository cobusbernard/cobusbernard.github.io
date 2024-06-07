---
title: Home VPN with OpenVPN
description: Using the guide in the previous post to set up a VPN to access your home network securely.
date: 2015-02-14
categories: [Linux]
tags: [linux, openvpn, vpn, docker]
aliases:
  - /linux/2015/02/14/openvpn-home
  - /linux/2015/02/14/openvpn-home.html
---

Having just set up an [external VPN](/posts/2015-02-13/openvpn-on-digital-ocean/) to pretend to be in the US, I wanted one to get into my home network as well when on the road. I ran into the issue while in the USA recently where I was unable to purchase [Steam](http://store.steampowered.com/) games as their servers picked up that I was in the States, but my payment method was South African. Never thought I would need to [spoof my own IP Address to pretend to be in South Africa](https://twitter.com/cobusbernard/status/554462128485457921).

The installation was almost exactly the same with one exception - I needed to install AppArmour as it wasn't part of my system at that point. My little [HP N40L](http://www8.hp.com/h20195/v2/GetDocument.aspx?docname=c04111079) that serves as a home file / XBMC server started out as an [Ubuntu 12.04](http://releases.ubuntu.com/12.04/) server and I needed to do a dist-upgrade on it. For a system that has been running a software, 4-disk RAID-5 using  [MDADM](http://en.wikipedia.org/wiki/Mdadm) for a few years, I was a bit worried that something would break. But it is just a server that I play with, worst case I would need to redo it. Eyes closed, fingers crossed, I started with the upgrade:

```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade

sudo apt-get install apparmor
```

After a while (remember, this is Africa where we have [really slow bandwidth](http://www.netindex.com/download/allcountries/) - you can find us at #122), the upgrade was done. A reboot later, and all seemed to still be working. OpenVPN installation took longer than yesterday, but only due to the bandwidth constraints. Only thing remaining was to expose the udp/1194 port to the external world. I have a [RouterBoard 750GL](http://routerboard.com/RB750GL) that I use for my firewall at home, a single command sorted this out for me:

```bash
/ip firewall nat add chain=dstnat protocol=udp dst-port=1194 \
    action=dst-nat to-addresses=10.0.0.1 to-ports=1194 in-interface=uncapped
```
