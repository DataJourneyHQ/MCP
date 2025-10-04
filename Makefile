DOCKER ?= docker
IMAGE_NAME ?= datajourney_mcp
CONTAINER_NAME ?= datajourney_mcp
PORT ?= 8000

.PHONY: build run stop clean

build:
	$(DOCKER) build -t $(IMAGE_NAME) .

run: build
	$(DOCKER) run --rm --name $(CONTAINER_NAME) -p $(PORT):$(PORT) -it $(IMAGE_NAME)

stop:
	-$(DOCKER) stop $(CONTAINER_NAME)

clean:
	-$(DOCKER) rm -f $(CONTAINER_NAME)
	-$(DOCKER) rmi -f $(IMAGE_NAME)
