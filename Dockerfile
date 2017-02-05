FROM ubuntu:14.04.5

RUN apt-get update \
      && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:brightbox/ruby-ng
RUN apt-get update

RUN apt-get -y upgrade

RUN apt-get install -y ruby2.2 ruby2.2-dev make gcc nodejs zlib1g-dev

RUN gem install jekyll --no-rdoc --no-ri \
      && gem install github-pages --no-rdoc --no-ri \
      && gem install jekyll-gist --no-rdoc --no-ri

RUN rm -rf /var/lib/apt/lists/*

WORKDIR "/site"

ENTRYPOINT ["jekyll", "serve", "--watch", "--host", "0.0.0.0"]
