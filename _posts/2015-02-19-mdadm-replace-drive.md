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

~~~
# mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb1 /dev/sdc1 /dev/sdd1

# cat /proc/mdstat
md0 : active raid5 sdd1[3] sdc1[1] sdb1[0]
      4294702080 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/2] [UU_]
      [====>................]  recovery = 20.1% (433131624/2147351040) finish=420.1min speed=68006K/sec
~~~

As you can see from the above, this isn't very fast. I found [this article](http://www.cyberciti.biz/tips/linux-raid-increase-resync-rebuild-speed.html) with some tips on increasing the speed. The one that worked for me was increasing the `stripe-cache_size` (tip 3):

~~~
# echo 32768 > /sys/block/md0/md/stripe_cache_size

md0 : active raid5 sdd1[3] sdc1[1] sdb1[0]
      4294702080 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/2] [UU_]
      [====>................]  recovery = 24.3% (523330980/2147351040) finish=147.1min speed=183976K/sec
~~~

Much better, about 3x faster.


**Original**
With all the load shedding, a drive failed in my software raid array. It is a [Raid-5](http://en.wikipedia.org/wiki/Standard_RAID_levels#RAID_5) setup, so I had time to replace the drive and rebuild the array. I was lucky with this failure as I randomly looked at my [mdadm](http://en.wikipedia.org/wiki/Mdadm) array today - I **really** need to set up the mail details to allow the system to mail me when something fails. Here is the command to check the health of your arrays:

~~~
cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md0 : active raid5 sdc1[2] sda1[0] sdb1[1]
      2929890816 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/3] [UUU_]

unused devices: <none>
~~~

Replacing the broken drive
---

The `[UUU_]` indicates that one of the drives is no longer part of the array. To see which drive is faulty, run `mdadm --detail /dev/md0` to get the details:

~~~
/dev/md0:
        Version : 1.2
  Creation Time : Mon Jun 23 20:08:17 2014
     Raid Level : raid5
     Array Size : 2929890816 (2794.16 GiB 3000.21 GB)
  Used Dev Size : 976630272 (931.39 GiB 1000.07 GB)
   Raid Devices : 4
  Total Devices : 3
    Persistence : Superblock is persistent

    Update Time : Fri Feb 17 08:24:12 2015
          State : clean, degraded
 Active Devices : 3
Working Devices : 3
 Failed Devices : 0
  Spare Devices : 0

         Layout : left-symmetric
     Chunk Size : 512K

           Name : Token:0  (local to host Token)
           UUID : 0b9ec9a1:73b38783:7bccad64:04b10ed8
         Events : 758663

    Number   Major   Minor   RaidDevice State
       0       8        1        0      active sync   /dev/sda1
       1       8       17        1      active sync   /dev/sdb1
       2       8       33        2      active sync   /dev/sdc1
       4       0        0        3      removed
~~~

This indicated that the last drive `/dev/sdd1` was missing. To figure out which drive this is, you can grab the serial number using [SmartMontools](http://www.smartmontools.org/)

~~~bash
sudo apt-get install smartmontools

smartctl -a /dev/sdd | grep Serial
Serial Number:    3NX12345
~~~

Time to open up the server and find the faulty drive. My server has hot swap bays and I guessed 'sdd' to be the fourth drive, so got the right one on my first attempt. Replaced the drive with a spare I had - originally I ran a 8x 1TB Raid-5 array on a different server, but the power usage was too high, so scaled things down a bit. To get the backup drive correctly partitioned, I deleted all the existing partitions and added a new one with file-system type 'fd' for 'Linux Raid autodetect' using `fdisk`. To add the disk back into the array, use `mdadm --manage /dev/md0 --add /dev/sdd1`. To check the progress, look at `/proc/mdstat`:

~~~
cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md0 : active raid5 sdd1[4] sdc1[2] sda1[0] sdb1[1]
      2929890816 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/3] [UUU_]
      [>....................]  recovery =  0.0% (190080/976630272) finish=256.8min speed=63360K/sec

unused devices: <none>
~~~

All good, now just need to wait till the rebuild is complete. It is advisable to stop all processes / applications during this period to speed up the rebuild. In my case, stopping [XMBC](http://kodi.tv/) increased the speed by 10x. Once the rebuild is complete, you should see something like this:

~~~
cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md0 : active raid5 sdd1[4] sdc1[2] sda1[0] sdb1[1]
      2929890816 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]

unused devices: <none>
~~~

Notifications for future failures
---

Now to ensure we get notified about any future fails, we need to set up mailing. I found [this post](http://ubuntuforums.org/showthread.php?t=1185134) which looked to be what I needed. Here is the short version:

~~~bash
sudo apt-get install msmtp msmtp-mta
~~~

To find the global configuration file, use `msmtp --version | grep "System configuration"`:

~~~
System configuration file name: /etc/msmtprc
~~~

Edit the file with `sudo vi /etc/msmtprc` and add (remember to replace with your specific details and also to enable SMTP on your GMail account):

~~~
# ------------------------------------------------------------------------------
# msmtp System Wide Configuration file
# ------------------------------------------------------------------------------

# A system wide configuration is optional.
# If it exists, it usually defines a default account.
# This allows msmtp to be used like /usr/sbin/sendmail.

# ------------------------------------------------------------------------------
# Accounts
# ------------------------------------------------------------------------------

# gmail account
# Configuring for gmail is beyond the scope of this tutorial
# Googling for "gmail msmtp" should help
account gmail
host smtp.gmail.com
port 587
from youremail@gmail.com
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
auth on
user youremail
password supersecret
syslog LOG_MAIL

# Other ISP Account
# Configuring for other ISPs is beyond the scope of this tutorial
# Googling for "myisp outlook smtp" should help

# ------------------------------------------------------------------------------
# Configurations
# ------------------------------------------------------------------------------

# Construct envelope-from addresses of the form "user@oursite.example".
#auto_from on
#maildomain fermmy.server

# Use TLS.
#tls on
#tls_trust_file /etc/ssl/certs/ca-certificates.crt

# Syslog logging with facility LOG_MAIL instead of the default LOG_USER.
# Must be done within "account" sub-section above
#syslog LOG_MAIL

# Set a default account
account default : gmail

# ------------------------------------------------------------------------------
~~~

To test, run `echo "This is a test e-mail from my server using msmtp" | msmtp -d youremail@gmail.com`. It should print out multiple lines, any error will be clearly displayed as such, i.e.

~~~
--> AUTH PLAIN AGNvYnVzYXyXbmFyZGuYYmthdnFiam9seXZlaGJiZA==
<-- 535-5.7.8 Username and Password not accepted. Learn more at
<-- 535 5.7.8 http://support.google.com/mail/bin/answer.py?answer=14257 n1sm2519061wib.11 - gsmtp
msmtp: authentication failed (method PLAIN)
msmtp: server message: 535-5.7.8 Username and Password not accepted. Learn more at
msmtp: server message: 535 5.7.8 http://support.google.com/mail/bin/answer.py?answer=14257 n1sm2519061wib.11 - gsmtp
msmtp: could not send mail (account default from /etc/msmtprc)
~~~

Now to replace the `sendmail` command with `msmtp`:

~~~
sudo mv /usr/sbin/sendmail /usr/sbin/sendmail.bak
sudo ln -s /usr/bin/msmtp /usr/sbin/sendmail
~~~

Add these lines to you `/etc/mdadm/mdadm.conf` file:

~~~
# instruct the monitoring daemon where to send mail alerts
MAILADDR youremail@domain.com
MAILFROM my-server-name - mdadm
~~~

Then to test, use `sudo mdadm --monitor --scan --test --oneshot`. If all is set up correctly, you should get a mail like this:

~~~
This is an automatically generated mail message from mdadm
running on Token

A SparesMissing event had been detected on md device /dev/md0.

Faithfully yours, etc.

P.S. The /proc/mdstat file currently contains the following:

Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md0 : active raid5 sdc1[2] sdb1[1] sda1[0] sdd1[4]
      2929890816 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]

unused devices: <none>
~~~

So after all that, you should be notified when something goes wrong and be able to correct it before loosing all your data.
