---
layout: post
title: Ubuntu on Hyper-V
exclude_comments: false
tagline: Tun times getting Ubuntu to run on Hyper-V.
image:
categories: [linux]
tags: [linux, ubuntu, hyper-v]
fullview: false
---
Getting Ubuntu to run on Hyper-V was a bit of an issue for Windows Server 2008, here are some things to look for.
In the boot menu, add vga16fb.modeset=0 to the boot options by hitting F6 to disable framebuffer mode that is **really** slow under Hyper-V.

Do normal install, don’t worry about the red “can’t find network issue”.

Enable the Hyper-V modules:

~~~
echo "hv_vmbus" >> /etc/initramfs-tools/modules
echo "hv_storvsc" >> /etc/initramfs-tools/modules
echo "hv_blkvsc" >> /etc/initramfs-tools/modules
echo "hv_netvsc" >> /etc/initramfs-tools/modules
update-initramfs –u
~~~

Disable Framebuffer (otherwise the text screen scrolls by like a 9600 modem)

~~~
echo "blacklist vga16fb" >> /etc/modprobe.d/blacklist-framebuffer.conf
~~~

Add networking config to /etc/network/interfaces:

~~~
auto eth0
iface eth0 inet loopback
Static:
Auto eth0
iface eth0 inet static
address [insert your IP address]
netmask [insert your netmask]
Gateway [insert your gateway address]
~~~

If you see something about /dev/sdaX not begin writable during the apt-get upgrade process, do this:

NB!!!! Make sure that power management is set to Maximum performance, otherwise you get a 18560 “triple fault” error.

Update: This is not entirely Hyper-V’s fault, its the way the grub update goes. Do this:

~~~
apt-get update
apt-get install -u grub
~~~

Then edit /etc/default/grub:

~~~
GRUB_CMDLINE_LINUX="ide0=noprobe ide1=noprobe hda=noprobe hdb=noprobe"
GRUB_DISABLE_LINUX_UUID=true
~~~

And run:

~~~
update-grub
~~~

Change fstab from UUID to /dev/sdaX.

REBOOT!!! The upgrade your system again.

~~~
apt-get upgrade
~~~

Read here for more info:
http://ubuntuforums.org/archive/index.php/t-1641951.html
http://blogs.msdn.com/b/virtual_pc_guy/archive/2010/10/21/installing-ubuntu-server-10-10-on-hyper-v.aspx
