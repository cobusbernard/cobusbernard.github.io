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
	@docker run -tp 4000:4000 -v $(shell pwd):/site --name jekyll-blog cobusbernard/jekyll-blog:1.0.2

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
