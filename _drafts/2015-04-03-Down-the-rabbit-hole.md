---
layout: post
title: Down the rabbit hole
tagline: Trying to solve one problem ends up requiring multiple solutions.
image:
exclude_comments: false
categories: [ramblings]
tags: [coding, fun, why-i-code]
fullview: false
---

When I was setting up my blog back in February, I ran into what I initially thought was a fairly easy task: setting up a dynamically updating DNS entry for my [home VPN]({% post_url 2015-02-14-openvpn-home %}). The talk by [Aaron Patterson]() at [RubyFuza](http://rubyfuza.org) this year captured the journey perfectly: "The joy of programming." He discussed how you end up researching and solving problems every single day, usually by starting with one and in the process ending up with 10. And that is awesome.

My rabbit hole went something like this:
: * [DynDNS](http://dyn.com/dns/) was no longer free, so I decide to
* Move my DNS to [Amazon's Route 53](http://aws.amazon.com/route53/) as their API makes scripting a breeze.
* Which required [scripting the update]({% post_url 2015-02-17-route-53-dns-update-script %})
* And I wanted to capture this in a blog post, so I needed to be able to embed the code via a [Gist](https://gist.github.com/cobusbernard/8f7f99eeb9597d3a0979) - haven't done that from a bash shell before, so tried that out,
* Which required install installing gist via [brew](http://brew.sh/)
* Learning the definition of a [commit-ish](http://stackoverflow.com/questions/23303549/what-are-commit-ish-and-tree-ish-in-git)
* And how to [validate bash input parameters](http://stackoverflow.com/questions/6482377/bash-shell-script-check-input-argument),
* [Installing the AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* Which required installing [pip](https://pypi.python.org/pypi/pip)
* And finally creating multiple IAM security profiles to separate the domains in the event of a key/secret being compromised.

This took about 1 ~ 2 hours, but it was a load of fun. I am starting to classify people (mostly developers) into 2 camps: those who love what they do, and those who are only in it for a paycheck at the end of the month.
