#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y ruby ruby-dev ruby2.0 ruby2.0-dev make gcc nodejs zlib1g-dev
sudo gem install jekyll --no-rdoc --no-ri
sudo gem install github-pages --no-rdoc --no-ri

jekyll -v
