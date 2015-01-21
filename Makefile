CURRENT_DIRECTORY := $(shell pwd)

build:
	@docker build --tag=iiiepe/nginx-drupal6 $(CURRENT_DIRECTORY)

.PHONY: build