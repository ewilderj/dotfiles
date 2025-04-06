.PHONY: container test clean interactive

IMAGE_NAME = dotfiles-test

container: Dockerfile
	@echo "Building container image $(IMAGE_NAME)"
	podman build -t $(IMAGE_NAME) .

test: container
	podman run --rm --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:rw $(IMAGE_NAME) make -C tests test

interactive: container
	podman run --rm -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:rw $(IMAGE_NAME) /bin/zsh

clean:
	podman rmi $(IMAGE_NAME) || true