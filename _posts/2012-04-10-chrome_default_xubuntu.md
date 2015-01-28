---
layout: post
title: Chrome as default browser in Xubuntu
exclude_comments: false
categories: [setup, linux]
tags: [linux, config]
fullview: true
---

If you need to set [Chrome](https://www.google.com/chrome/browser/desktop/) as the default browser in [Xubuntu](http://xubuntu.org/), run the following from your terminal:

~~~
gconftool-2 --type string -s /desktop/gnome/url-handlers/http/command "google-chrome %s"
~~~
