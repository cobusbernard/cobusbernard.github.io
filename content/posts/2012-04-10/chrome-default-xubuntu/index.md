---
title: Chrome as default browser in Xubuntu
description: How to get Chrome as you default browser in Xubuntu.
date: 2012-04-10
categories: [Linux]
tags: [linux, config, xubuntu]
aliases:
  - /linux/2012/04/10/chrome_default_xubuntu
---

If you need to set [Chrome](https://www.google.com/chrome/browser/desktop/) as the default browser in [Xubuntu](http://xubuntu.org/), run the following from your terminal:

```bash
gconftool-2 --type string -s /desktop/gnome/url-handlers/http/command "google-chrome %s"
```
