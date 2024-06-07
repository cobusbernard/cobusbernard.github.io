---
title: Migrating repo from SVN to Git RPC error
description: Interesting Git issues with large repositories
date: 2012-02-04
categories: ["Version Control"]
tags: [git, svn]
aliases:
  - /version%20control/2012/02/04/git-rpc-error
  - /version%20control/2012/02/04/git-rpc-error.html
---

While I was working on [Dementium II HD](http://www.dementium2.com), I wanted to migrate the repository from [SVN](https://subversion.apache.org/) to [Git](http://git-scm.com/). It was being hosted on a machine in the one studio and served the external developers over a 10mbit ADSL connection. The upstream rate is ~400kbit, so imagine trying to checkout a 26GB repository. I ran into the following error when I tried to import the SVN repo into a Git one:

```bash
$ git push -v origin svn-merge-trunk:svn-trunk
Pushing to https://git-repo/git
Counting objects: 2840, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2788/2788), done.
error: RPC failed; result=22, HTTP code = 411
fatal: The remote end hung up unexpectedly
Writing objects: 100% (2840/2840), 3.07 MiB | 474 KiB/s, done.
Total 2840 (delta 2202), reused 0 (delta 0)
fatal: The remote end hung up unexpectedly
```

After a bit of Googling, I found a solution for this:

```bash
$ git config http.postBuffer 524288000
$ git push -v origin master:master
Pushing to https://git-repo/git
Username:
Password:
Counting objects: 2843, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2790/2790), done.
Writing objects: 100% (2842/2842), 3.07 MiB | 5.54 MiB/s, done.
Total 2842 (delta 2204), reused 0 (delta 0)
```

Patting myself on the back and stopping mid-way to my back, I realized that both GitHub and BitBucket do not really support repos bigger than 1GB and I was sitting with 26GB :) All the art assets had been committed as part of the code repository and I did not know which were needed and which weren't. The other devs / designers on the team were not familiar with Git and we decided to rather stick with SVN on a micro [AWS](http://aws.amazon.com/) instance. Interestingly enough, the CPU on the micro instance affected checkout speed - when changed to a small instance, the checkout speed doubled.
