CURRENT_DIRECTORY := $(shell pwd)

build:
	@docker build --tag=iiiepe/nginx-drupal6 $(CURRENT_DIRECTORY)

build-no-cache:
	@docker build --tag=iiiepe/nginx-drupal6 --no-cache $(CURRENT_DIRECTORY)

.PHONY: build build-no-cache
