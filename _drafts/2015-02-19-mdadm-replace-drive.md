---
layout: post
title: Replacing mdadm drive
exclude_comments: false
categories: [Linux]
tags: [linux, mdadm]
fullview: false
---

With all the load shedding, a drive failed.

~~~
cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md0 : active raid5 sdc1[2] sda1[0] sdb1[1]
      2929890816 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/3] [UUU_]

unused devices: <none>
~~~


~~~
mdadm --manage /dev/md0 --add /dev/sdd1

cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md0 : active raid5 sdd1[4] sdc1[2] sda1[0] sdb1[1]
      2929890816 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/3] [UUU_]
      [>....................]  recovery =  0.0% (190080/976630272) finish=256.8min speed=63360K/sec

unused devices: <none>
~~~


~~~
cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md0 : active raid5 sdd1[4] sdc1[2] sda1[0] sdb1[1]
      2929890816 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]

unused devices: <none>
~~~


TODO: Add how to configure mailing the alert out.
