---
layout: post
title: Getting started with Chef
exclude_comments: false
tagline: Basics of Chef with multiple organisations
image:
categories: [DevOps]
tags: [linux, chef, configuration-management]
fullview: false
---

http://jtimberman.housepub.org/blog/2011/09/03/guide-to-writing-chef-cookbooks/
http://marksdevserver.com/2013/06/19/chef-bootstrap-autoscaled-ec2-instance/
http://atomic-penguin.github.io/blog/2013/04/25/Multi-Knife-HOWTO/
http://dougireton.com/blog/2013/02/16/chef-cookbook-anti-patterns/
https://www.chef.io/blog/2012/10/31/introducing-partial-search-for-opscode-hosted-chef/

First thing is to get a Chef server up and running. The easiest way to do this is sign up for a hosted one by [Chef](https://manage.chef.io/signup). You are limited to 5 nodes on the free tier, but that should be enough to get started. Once you decide to use Chef, [compare the cost](https://www.chef.io/pricing/) of self-hosted vs hosted and whether you want any of the additional features that are available for the paid version. After installing the server, you should have your personal `<your name>.pem` and a `validator.pem` key available. The personal key is used to interact with the Chef server as yourself and the validation one is used for provisioning new nodes. The intention is to bootstrap a node using the validation key and then to remove it from the host. The bootstrapping process will use the `validator.pem` key to encrypt the communication to the Chef server and using that secure channel, generate a client specific key to use for future interactions.

Next you need to get `knife` installed and configured locally to interact with the Chef server. Install the [Chef DK](https://downloads.chef.io/chef-dk/) and configure [knife](https://docs.chef.io/config_rb_knife.html). A simple configuration could look like this:

~~~
log_level                :info
log_location             STDOUT
client_key               "~/.chef/cobus.pem"
validation_key           "~/.chef/validator.pem"
chef_server_url          'https://api.chef.io/organizations/myorganization'
validation_client_name   'myorganization-validator'
node_name                'cobus'
syntax_check_cache_path  '~/.chef/syntax_check_cache'
cookbook_license          ENV['COOKBOOK_LICENSE'] || 'apachev2'
cookbook_copyright        ENV['COOKBOOK_COPYRIGHT'] || 'Cobus Bernard'
cookbook_email            ENV['COOKBOOK_EMAIL'] || 'me@cobus.io'
~~~

If you are interested in a multi-organization setup, have a look at this [blog post](http://atomic-penguin.github.io/blog/2013/04/25/Multi-Knife-HOWTO/). My `~/.zshrc` has this at the end:

{% highlight bash %}
CHEF_ORGNAME=my-home-network
COOKBOOK_COPYRIGHT="Cobus Bernard"
COOKBOOK_EMAIL=me@cobus.io
COOKBOOK_LICENSE=mit
EDITOR=vi
export CHEF_ORGNAME EDITOR

function knife-client-1 {
  CHEF_ORGNAME=client1
  COOKBOOK_COPYRIGHT=Client 1
  COOKBOOK_EMAIL=cobus@client1
  COOKBOOK_LICENSE=mit
  export CHEF_ORGNAME COOKBOOK_COPYRIGHT COOKBOOK_EMAIL COOKBOOK_LICENSE
}

function knife-client-2 {
  CHEF_ORGNAME=client-2
  COOKBOOK_COPYRIGHT=Client 2
  COOKBOOK_EMAIL=cobus2@client2
  COOKBOOK_LICENSE=apachev2
  export CHEF_ORGNAME COOKBOOK_COPYRIGHT COOKBOOK_EMAIL COOKBOOK_LICENSE
}

function knife-home {
  CHEF_ORGNAME=my-home-network
  COOKBOOK_COPYRIGHT="Cobus Bernard"
  COOKBOOK_EMAIL=me@cobus.io
  COOKBOOK_LICENSE=mit
  export CHEF_ORGNAME COOKBOOK_COPYRIGHT COOKBOOK_EMAIL COOKBOOK_LICENSE
}
{% endhighlight %}

And my `~/.chef/knife.rb`:

{% highlight ruby %}
log_level                :info
log_location             STDOUT
client_key               "~/.chef/#{ENV['CHEF_ORGNAME']}-cobus.pem"
validation_key           "~/.chef/#{ENV['CHEF_ORGNAME']}-validator.pem"
if ENV['CHEF_ORGNAME'] == 'client1'
  chef_server_url          'https://client1:443/organizations/client1'
  validation_client_name   'client1-validator'
  node_name                'cobus'
elsif ENV['CHEF_ORGNAME'] == 'client2'
  chef_server_url          'https://chef.client2/organizations/client2'
  validation_client_name   'validator'
  node_name                'cobus.bernard'
elsif ENV['CHEF_ORGNAME'] == 'my-home-network'
  chef_server_url          'https://api.chef.io/organizations/my-home-network'
  validation_client_name   'my-home-network-validator'
  node_name                'cobusbernard'
end
syntax_check_cache_path  '~/.chef/syntax_check_cache'

cookbook_license         ENV['COOKBOOK_LICENSE'] || 'apachev2'
cookbook_copyright       ENV['COOKBOOK_COPYRIGHT'] || 'Cobus Bernard'
cookbook_email           ENV['COOKBOOK_EMAIL'] || 'me@cobus.io'
{% endhighlight %}

By default I will interact with my personal Chef server - if you deal with multiple client installations, this is a safety net as it would be *very* embarrassing to upload the cookbook for `client1` to `client2`'s server. To verify that you have everything configured correctly, run `knife status`. This should return a blank line if everything is correctly configured.

With Chef, there are a lot of different ways to do the same thing. I will be covering the usage of [Berkshelf](http://berkshelf.com/). It ships as part of the ChefDK, just run `berks` to ensure it is installed and added to your path. Let's create a sample cookbook: `berks cookbook sample_cookbook`.

~~~
berks cookbook sample_cookbook
      create  sample_cookbook/files/default
      create  sample_cookbook/templates/default
      create  sample_cookbook/attributes
      create  sample_cookbook/libraries
      create  sample_cookbook/providers
      create  sample_cookbook/recipes
      create  sample_cookbook/resources
      create  sample_cookbook/recipes/default.rb
      create  sample_cookbook/metadata.rb
      create  sample_cookbook/LICENSE
      create  sample_cookbook/README.md
      create  sample_cookbook/CHANGELOG.md
      create  sample_cookbook/Berksfile
      create  sample_cookbook/Thorfile
      create  sample_cookbook/chefignore
      create  sample_cookbook/.gitignore
      create  sample_cookbook/Gemfile
      create  .kitchen.yml
    conflict  chefignore
Overwrite /Users/cobus/Projects/Research/sample_cookbook/chefignore? (enter "h" for help) [Ynaqdh] Y
       force  chefignore
      append  Thorfile
      create  test/integration/default
      append  .gitignore
      append  .gitignore
      append  Gemfile
      append  Gemfile
You must run `bundle install' to fetch any new gems.
      create  sample_cookbook/Vagrantfile
~~~

This will create a folder structure as follows (remember to run `bundle install` after you create the cookbook):

~~~
sample_cookbook git:(master) ✗ tree
.
├── Berksfile
├── CHANGELOG.md
├── Gemfile
├── LICENSE
├── README.md
├── Thorfile
├── Vagrantfile
├── attributes
├── chefignore
├── files
│   └── default
├── libraries
├── metadata.rb
├── providers
├── recipes
│   └── default.rb
├── resources
├── templates
│   └── default
└── test
    └── integration
        └── default
~~~

The basic unit that does work is called a _recipe_ and is contained inside a _cookbook_. Each cookbook has a _default_ recipe that will be run if you do not specify one to run. A recipe is a set of steps to execute when it is run and you group recipes for the different tasks in an area you want done inside the cookbook. I.e. the [Apt](https://github.com/chef-cookbooks/apt) cookbook will allow you to update the `apt` cache ([default recipe](https://github.com/chef-cookbooks/apt/blob/master/recipes/default.rb)), use `apt-cacher-ng` server as a client ([cacher-client recipe](https://github.com/chef-cookbooks/apt/blob/master/recipes/cacher-client.rb)), or install `apt-cacher-ng` package to use ([cacher-ng recipe](https://github.com/chef-cookbooks/apt/blob/master/recipes/cacher-ng.rb)). Recipes use a DSL that is built with Ruby and allows you to use Ruby statements like `if` and `case` statements. More detail can be seen in the [Chef docs](https://docs.chef.io/dsl_recipe.html).

The power of configuration management tools comes from leveraging existing solutions to problems other have already solved, i.e. how to update Apt prior to installing packages. There are 2 facets to this:

* Being able to specify the use of another cookbook.
* Being able to upload your cookbook and any dependencies to the Chef server.

In Chef, you specify the dependencies in the `metadata.rb` file via a `depends` statement like this:

~~~
depends 'apt', '~> 2.9.2'
~~~

This instructs Chef to use the cookbook called `apt` in the [Chef Supermarket](https://supermarket.chef.io/) and look for any version that is _pessimistically greater than_ `2.9.2`. This indicates that hotfixes (`2.9.x >= 2.9.2`) may be used if available, but not any new feature (`2.x.x`) / breaking (`3.x.x`) changes. This prevents the cookbook from failing when a new feature (i.e. _default_ now also sets something else) or a breaking change (the _default_ cookbook now install apt-v99) is added to the cookbook you dependend on. When you run into an issue with a community cookbook, you can either report the issue and wait for them to fix it, or fix it yourself and submit a pull-request. For the latter, you would want to use the modified version and not wait for them to fix it, so you need a mechanism to specify both the version, branch and git location of the cookbook. [Berkshelf](http://berkshelf.com) handles a lot of the complexity for us. The `Berksfile` is used indicate specific locations of a dependent cookbook when you want to use a custom repo *and* branch. As Berkshelf will read your `metadata.rb` for dependencies when you specify `metadata` in the `Berksfile`, it will pick up your dependencies as specified in `metadata.rb`. For a custom repo, branch and version, you can use `cookbook 'datadog', '~> 2.2.0', github: 'cobusbernard/chef-datadog', branch: "feature/Add_Windows_Service"`. (In this instace I needed some feature for Windows in the DataDog client that wasn't completed yet.).

Now that we can build on top of other cookbooks, it is time to push our cookbook (and its dependencies) to the Chef server. Once again, Berkshelf makes this very simple for us via `berks install` and `berks upload`. Before you can push the cookbooks to Chef, you need to have a copy locally. The `install` command of Berkshelf will download them for you and keep a versioned copy in `~/.berkshelf/cookbooks`. The `upload` command will upload the required ones to the Chef server.

~~~
sample_cookbook git:(master) ✗ berks install
Resolving cookbook dependencies...
Fetching 'sample_cookbook' from source at .
Fetching cookbook index from https://supermarket.chef.io...
Using apt (2.9.2)
Using sample_cookbook (0.1.0) from source at .

sample_cookbook git:(master) ✗ berks upload
Skipping apt (2.9.2) (frozen)
Uploaded sample_cookbook (0.1.0) to: 'https://api.chef.io:443/organizations/my-home-network'
~~~

As I already had the `apt` cookbook uploaded, Berkshelf didn't upload it again. When you make changes to your cookbook after uploading it, you also need to bump the version number in `metadata.rb`, or Berkshelf won't upload it for you:

~~~
sample_cookbook git:(master) ✗ berks upload
Skipping apt (2.9.2) (frozen)
Skipping sample_cookbook (0.1.0) (frozen)
~~~

It is also good practice to update the `CHANGELOG.md` with what changed for others who use the cookbook to easily read without looking at the commits.

To run this recipe on a node, you can bootstrap one using `knife bootstrap 10.0.0.1 -x myuser --sudo -P mypassword --use-sudo-password -r "recipe[sample_cookbook::default]" --environment "_default"`. This will install the latest Chef client on the node and register it with the Chef server. This should result in output like this:

~~~
~~~



roles

data bags

attributes

environments
