#!/bin/bash

sudo add-apt-repository -y ppa:brightbox/ruby-ng

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install ruby2.1 ruby2.1-dev make gcc nodejs zlib1g-dev
sudo gem install jekyll --no-rdoc --no-ri
sudo gem install github-pages --no-rdoc --no-ri

