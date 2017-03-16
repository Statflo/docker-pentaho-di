VERSION := latest
IMAGE   := docker-kitchenpan:$(VERSION)

build:
	@docker build $(BUILD_EXT) -t "$(IMAGE)" "$(CURDIR)"

run-test-job:
	@docker run -it "$(IMAGE)" kitchen.sh -rep=docker-pentaho-di -dir=/ -job=test-job
