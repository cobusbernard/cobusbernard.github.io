---
title: Using SSH Config
description: Setting up various SSH host configs to simplify access.
date: 2012-04-12
categories: [Linux]
tags: [config, ssh, linux]
aliases:
  - /linux/2012/04/12/ssh-config-multiple-keys
  - /linux/2012/04/12/ssh-config-multiple-keys.html
---

If you use [SSH](http://www.openssh.com/) on Linux a lot, you will know that having to specify the key each time you want to access a server is a pain. You really don't want to have a single key for all servers as you would need to revoke it globally in the event that it was compromised. The ssh config file allows you to specify multiple values to use for specific hosts:

To edit the ssh config, open it in [vim](http://www.vim.org/) (or your favourite editor):

```bash
vi ~/.ssh/config
```

Add the following to it:

```bash
Host {personalaccount}.unfuddle.com
IdentityFile ~/.ssh/id_rsa
IdentitiesOnly yes
User {personaluser}

Host {companyaccount}.unfuddle.com
IdentityFile ~/.ssh/{companyaccount}_rsa
IdentitiesOnly yes
User {mycompanyuser}
```

This will allow you to use different keys depending on if you are accessing the server using your personal or company user. This becomes very useful when dealing with multiple repositories hosted on the same service.
