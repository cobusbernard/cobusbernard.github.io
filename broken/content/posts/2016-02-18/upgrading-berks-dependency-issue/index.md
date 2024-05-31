---
title: Upgrading a Chef cookbook with Berkshelf
description: Ran into an issue when trying to upgrade a dependency cookbook.
date: 2016-02-18
categories: [DevOps]
tags: [chef]
aliases:
  - /2016/02/18/Upgrading_Berks_Dependency_Issue
---

I just upgraded my chef-clients via the [omnibus_updater](https://github.com/hw-cookbooks/omnibus_updater) cookbook when things started breaking:

```bash
192.168.5.5 [2016-02-18T21:41:13+02:00] WARN: Current  apt_package[apt-transport-https]: /var/chef/cache/cookbooks/datadog/recipes/repository.rb:24:in `from_file'
192.168.5.5
192.168.5.5   ================================================================================
192.168.5.5   Recipe Compile Error in /var/chef/cache/cookbooks/chef-wrapper-omnibus-updater/recipes/default.rb
192.168.5.5   ================================================================================
192.168.5.5
192.168.5.5   NameError
192.168.5.5   ---------
192.168.5.5   uninitialized constant Chef::REST
192.168.5.5
192.168.5.5   Cookbook Trace:
192.168.5.5   ---------------
192.168.5.5     /var/chef/cache/cookbooks/omnibus_updater/libraries/omnitrucker.rb:84:in `url'
192.168.5.5     /var/chef/cache/cookbooks/omnibus_updater/recipes/downloader.rb:27:in `from_file'
192.168.5.5     /var/chef/cache/cookbooks/omnibus_updater/recipes/default.rb:25:in `from_file'
192.168.5.5     /var/chef/cache/cookbooks/chef-wrapper-omnibus-updater/recipes/default.rb:27:in `from_file'
192.168.5.5
192.168.5.5   Relevant File Content:
192.168.5.5   ----------------------
192.168.5.5   /var/chef/cache/cookbooks/omnibus_updater/libraries/omnitrucker.rb:
192.168.5.5
192.168.5.5    77:        if(url_or_node.is_a?(Chef::Node))
192.168.5.5    78:          url = build_url(url_or_node)
192.168.5.5    79:          node = url_or_node
192.168.5.5    80:        else
192.168.5.5    81:          url = url_or_node
192.168.5.5    82:          raise "Node instance is required for Omnitruck.url!" unless node
192.168.5.5    83:        end
192.168.5.5    84>>       request = Chef::REST::RESTRequest.new(:head, URI.parse(url), nil)
192.168.5.5    85:        result = request.call
192.168.5.5    86:        if(result.kind_of?(Net::HTTPRedirection))
192.168.5.5    87:          result['location']
192.168.5.5    88:        end
192.168.5.5    89:      end
192.168.5.5    90:
192.168.5.5    91:    end
192.168.5.5    92:  end
192.168.5.5    93:
```

Googling for `uninitialized constant Chef::REST` only yielded some results from March 2013, so I decided to upgrade the `omnibus_updater` cookbook from `1.0.4.` to `1.0.6` by editing `metadata.rb`. I bumped the dependency version as well as my wrapper cookbook version, but when I ran `berks install`, I got the following:

```bash
Resolving cookbook dependencies...
Fetching 'chef-wrapper-omnibus-updater' from source at .
Fetching cookbook index from https://supermarket.chef.io...
Unable to satisfy constraints on package omnibus_updater due to solution constraint (omnibus_updater = 1.0.4). Solution constraints that may result in a constraint on omnibus_updater: [(chef-wrapper-omnibus-updater = 0.1.2) -> (omnibus_updater ~> 1.0.6)], [(omnibus_updater = 1.0.4)]
Demand that cannot be met: (omnibus_updater = 1.0.4)
Artifacts for which there are conflicting dependencies: omnibus_updater = 1.0.4 -> []Unable to find a solution for demands: chef-wrapper-omnibus-updater (0.1.2), omnibus_updater (1.0.4)
```

That at least had some Google results, ends up that I need to upgrade via `berks update omnibus_updater` instead of just incrementing the version number. After the upgrade, the other issue was also resolved.
