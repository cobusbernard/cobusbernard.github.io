---
layout: post
title: Yak Shaving - Makefiles
exclude_comments: false
tagline: Creating my first makefile
image:
categories: [Linux]
tags: [docker, osx, make, scripts]
fullview: false
---

The Problem
-----------

I woke up this morning wanting to start on a long post about [Terraform](https://terraform.io) and how I ended up with the structure shown [in my repo](https://github.com/cobusbernard/tf-aws-multi-account). I recently reinstalled my Macbook ([using Netatalk for a timemachine]({% post_url 2017-01-15-Timemachine_backups %})), and as I fired up my vagrant image, it started to pull down the Ubuntu box first and then started configuring it. This is very useful, but it is slow. And it broke. I forgot to add `-y` to the `apt-get` when I initially created the install script:

~~~
==> jekyll: Do you want to continue?
==> jekyll:  [Y/n]
==> jekyll: Abort.
~~~

I have been working with [docker](https://www.docker.com/) a lot at work and while running a 3 node [Mesos](http://mesos.apache.org/) + [Marthon](https://mesosphere.github.io/marathon/) cluster at home (future post +1). Inspired by the [DevOpsDays](http://www.devopsdays.org) site, I wanted to have my own container to work with when writing blog posts. (And convince myself that doing this will make me more efficient and therefore create more blog entries...). While I'm at it, I wanted to use a `Makefile`. I have encountered them before, but never created one, so I decided on the following Yaks to shave:

1. Create and use a container to run the site
2. Build the container using a Makefiles
3. (Found later) Upgrade to Ruby 2.2.5

Creating the container via Makefile
-----------------------------------

First hit in Google for [getting started with makefiles](https://www.google.co.za/search?q=getting+started+with+makefiles&oq=getting+started+with+makefiles) yielded [this site](http://www.cprogramming.com/tutorial/makefiles.html). Seems fairly straightforward. I always want some default behaviour in a command that doesn't break anything and explains what it does when you run it without any parameters. To do so, I created the first target as `default` with a nice little message describing the available targets:

~~~
default:
	echo "This file is used to work with the cobus.io Jekyll blog site."
	echo "The following commands are available:"
	echo " - docker : builds the docker container to run the site locally."
	echo " - run    : runs the docker container with the site"
~~~

Running `make` outputs the following:

~~~
~/Projects/Sites/cobus.io git:(master) ✗  17-02-05 8:25 make
echo "This file is used to work with the cobus.io Jekyll blog site."
This file is used to work with the cobus.io Jekyll blog site.
echo "The following commands are available:"
The following commands are available:
echo " - docker : builds the docker container to run the site locally."
 - docker : builds the docker container to run the site locally.
echo " - run    : runs the docker container with the site"
 - run    : runs the docker container with the site
~~~

Damn, that is ugly. So how do I hide the command ala `echo off`? Google! Prefix it with an `@`.

~~~
default:
	@echo "This file is used to work with the cobus.io Jekyll blog site."
	@echo "The following commands are available:"
	@echo " - docker : builds the docker container to run the site locally."
	@echo " - run    : runs the docker container with the site"
~~~

This looks a lot better:

~~~
➜  ~/Projects/Sites/cobus.io git:(master) ✗  17-02-05 8:25 make
This file is used to work with the cobus.io Jekyll blog site.
The following commands are available:
 - docker : builds the docker container to run the site locally.
 - run    : runs the docker container with the site
~~~

I started with the `docker` target to create the container to be able to see if my ramblings here render correctly. Additionally, I want to enforce a version number when building the container (I love version numbers). It will allow pegging which version of the container to use when running this blog as well as check out historic points in time and still be able to run the blog. I found [this answer](http://stackoverflow.com/questions/38801796/makefile-set-if-variable-is-empty) for detecting missing variables and went for the multi-line option:

~~~
docker:
  ifeq ($(VERSION),)
    @echo "Please set the VERSION environment variable before building the continer."
    exit 1
  endif
  @echo "Preparing to build version [${VERSION}] of cobusbernard/jekyll-blog container..."
~~~

Which didn't work:

~~~
ifeq (,)
/bin/sh: -c: line 0: syntax error near unexpected token `,'
/bin/sh: -c: line 0: `ifeq (,)'
make: *** [docker] Error 2
~~~

That looks like it needs me to specify bash usage, so I added `SHELL:=/bin/bash` at the top of the `Makefile`. This still broke with the same error (`/bin/bash` instead of `/bin/sh`). [Found this solution](http://stackoverflow.com/questions/10858261/abort-makefile-if-variable-not-set) for dealing with unset variables, and changed it to:

~~~
docker:
	$(call check_defined, VERSION, Please set a version number)
	@echo "Preparing to build version [${VERSION}] of cobusbernard/jekyll-blog container..."

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))
~~~

Yay! Success!

~~~
~/Projects/Sites/cobus.io git:(master) ✗  17-02-05 9:11 make docker
Makefile:10: *** Undefined VERSION (Please set a version number).  Stop.

~/Projects/Sites/cobus.io git:(master) ✗  17-02-05 9:12 VERSION=1.0.0 make docker
Preparing to build version [1.0.0] of cobusbernard/jekyll-blog container...
~~~

Building the docker image
-------------------------

Now for the `Dockerfile`. I prefer building my own containers from the base OS ones as it helps me understand what is required to run a piece of software. I added the previous `install_jekyll.sh` commands (along with the [cleanup suggested by Docker](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/))

~~~
FROM ubuntu:14.04.5

RUN apt-get update \
      && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:brightbox/ruby-ng
RUN apt-get update

RUN apt-get -y upgrade

RUN apt-get install -y ruby2.1 ruby2.1-dev make gcc nodejs zlib1g-dev

RUN gem install jekyll --no-rdoc --no-ri \
      && gem install github-pages --no-rdoc --no-ri

RUN rm -rf /var/lib/apt/lists/*
~~~

I usually start with very many `RUN` commands as our internet here in South Africa still isn't great (I have a ~20mbit LTE line) that is shared with everyone in the house. It is better to group the commands together to have less layers in the final image. There is a new feature in `1.13` of docker that allows squashing layers, I need to read up on that later.

Surprise, this also broke. Looks like I need to upgrade my Ruby version from `2.1` to `2.2` according to [this post](http://stackoverflow.com/questions/40085215/listen-conflict-when-installing-jekyll-with-docker). Once that was fixed, the container was built.

~~~
~/Projects/Sites/cobus.io git:(master) ✗  17-02-05 11:40 VERSION=1.0.0 make docker
Preparing to build version [1.0.0] of cobusbernard/jekyll-blog container...
Sending build context to Docker daemon 8.935 MB
Step 1/9 : FROM ubuntu:14.04.5
 ---> b969ab9f929b
Step 2/9 : RUN apt-get update       && apt-get install -y software-properties-common
 ---> Using cache
 ---> 7823e8cc46fa
Step 3/9 : RUN add-apt-repository -y ppa:brightbox/ruby-ng
 ---> Using cache
 ---> d5b1d17be061
Step 4/9 : RUN apt-get update
 ---> Using cache
 ---> 60a6cafc256b
Step 5/9 : RUN apt-get -y upgrade
 ---> Using cache
 ---> 05f66007ae38
Step 6/9 : RUN apt-get install -y ruby2.2 ruby2.2-dev make gcc nodejs zlib1g-dev
 ---> Using cache
 ---> 30bad4f00fb3
Step 7/9 : RUN gem install jekyll --no-rdoc --no-ri       && gem install github-pages --no-rdoc --no-ri
 ---> Using cache
 ---> 9d9c6af564df
Step 8/9 : RUN rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 3d7490d97763
Step 9/9 : ENTRYPOINT jekyll serve --watch /site
 ---> Using cache
 ---> 12c2ffb6c08d
Successfully built 12c2ffb6c08d
~~~

Once we have the container, we want to make it available to use again in future, so I created a repository for it under `cobusbernard/jekyll-blog`. To push to the repo, you will need to tag the container. Most repos will have a `latest` tag to use along with versioned ones. Adding the following to the `Makefile` target achieves that:

~~~
@echo "Tagging latest and pushing to Docker hub..."
@docker tag jekyll-blog:latest cobusbernard/jekyll-blog:latest
@docker push cobusbernard/jekyll-blog:latest
@echo "Tagging version ${VERSION} and pushing to Docker hub..."
@docker tag jekyll-blog:latest cobusbernard/jekyll-blog:${VERSION}
@docker push cobusbernard/jekyll-blog:${VERSION}
~~~

Lastly, we need to add an `ENTRYPOINT` for the container. Have a read [here](https://www.ctl.io/developers/blog/post/dockerfile-entrypoint-vs-cmd/) for the difference between an `ENTRYPOINT` and a `CMD` - in my case, I don't want to easily allow overwriting the command executed when the container starts as I like convention over configuration. When running the `jekyll serve` command, we need to ensure we are inside the correct directoy. For that, we need to add a `WORKDIR` directive. The final `Dockerfile` looks like this:

~~~
FROM ubuntu:14.04.5

RUN apt-get update \
      && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:brightbox/ruby-ng
RUN apt-get update

RUN apt-get -y upgrade

RUN apt-get install -y ruby2.2 ruby2.2-dev make gcc nodejs zlib1g-dev

RUN gem install jekyll --no-rdoc --no-ri \
      && gem install github-pages --no-rdoc --no-ri

RUN rm -rf /var/lib/apt/lists/*

WORKDIR "/site"

ENTRYPOINT ["jekyll", "serve", "--watch", "/site"]
~~~

It is safe to push this to a public Docker repository as there are no sensitive parts to it. When you start copying your code into a container, you might want to reconsider. Ideally if you are following the [12-factor app](https://12factor.net/) approach and you don't have any configuration secrets in your container. This might not be the only sensitive information though, i.e. your code-base might be considered sensitive if it has algorithms written in Python in it. It would be trivial to copy out the code from the container if that was the case.

Running the container and the blog
----------------------------------

The last step is to flesh out the `run` target to use this new container to run the blog. The commands look something like this in normal bash:

~~~
docker stop jekyll-blog
docker rm   jekyll-blog
docker run -tp 4000:4000 -v <current dictory>:/site --name jekyll-blog cobusbernard/jekyll-blog:1.0.0
~~~

The first 2 will fail the first time you run them as you haven't created a container with the name `jekyll-blog` before. On subsequent runs, they will succeed. So the first step is to indicate to `make` that the command might fail and to ignore that, [this post](http://stackoverflow.com/questions/3143635/how-to-ignore-mv-error)  explains how to do that in typical StackOverflow style: the marked answer is incorrect and the one below it with the most upvotes is the correct one. We also need to pass the current directory to `make`, usually you would use `$(pwd)`. [This post](http://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile) shows how to use `$(shell pwd)` for that purpose. The final `Makefile` looks like this:

~~~
SHELL:=/bin/bash

default:
	@echo "This file is used to work with the jekyll-blog Jekyll blog site."
	@echo "The following commands are available:"
	@echo " - docker : builds the docker container to run the site locally."
	@echo " - run    : runs the docker container with the site"

docker:
	$(call check_defined, VERSION, Please set a version number)
	@echo "Preparing to build version [${VERSION}] of cobusbernard/jekyll-blog container..."
	@docker build -t jekyll-blog .
	@echo "Tagging latest and pushing to Docker hub..."
	@docker tag jekyll-blog:latest cobusbernard/jekyll-blog:latest
	@docker push cobusbernard/jekyll-blog:latest
	@echo "Tagging version ${VERSION} and pushing to Docker hub..."
	@docker tag jekyll-blog:latest cobusbernard/jekyll-blog:${VERSION}
	@docker push cobusbernard/jekyll-blog:${VERSION}

run:
	@echo "Running the docker container cobusbernard/jekyll-blog to start Jekyll..."
	-@docker stop jekyll-blog
	-@docker rm   jekyll-blog
	@docker run -tp 4000:4000 -v $(shell pwd):/site --name jekyll-blog cobusbernard/jekyll-blog:1.0.0

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))
~~~

To run the site, I just execute `make run`. And viola:

~~~
~/Projects/Sites/cobus.io git:(master) ✗  17-02-05 12:19 make run
Running the docker container cobusbernard/jekyll-blog to start Jekyll...
jekyll-blog
jekyll-blog
Configuration file: /site/_config.yml
Configuration file: /site/_config.yml
            Source: /site
       Destination: /site/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
                    done in 3.487 seconds.
 Auto-regeneration: enabled for '/site'
Configuration file: /site/_config.yml
    Server address: http://0.0.0.0:4000/
  Server running... press ctrl-c to stop.

~~~
