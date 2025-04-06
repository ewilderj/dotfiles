PHONY: container test clean interactive

IMAGE_NAME = dotfiles-test

container: Dockerfile
	@echo "Building container image $(IMAGE_NAME)"
	podman build -t $(IMAGE_NAME) .

test: container
	podman run --rm $(IMAGE_NAME) make -C tests test

interactive: container
	podman run --rm -it $(IMAGE_NAME) /bin/zsh

clean:
	podman rmi $(IMAGE_NAME) || true