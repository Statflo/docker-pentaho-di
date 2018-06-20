VERSION := latest
IMAGE   := docker-pentaho-di:$(VERSION)

build:
	@docker build $(BUILD_EXT) -t "$(IMAGE)" "$(CURDIR)"

push:
	@docker push "$(IMAGE)"
