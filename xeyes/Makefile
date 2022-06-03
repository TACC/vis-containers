build:
	docker build -t xeyes:0.1 .

run:
	xhost + 127.0.0.1
	docker run -e DISPLAY=host.docker.internal:0 xeyes:0.1 xeyes

run-remote:
	docker run --rm --net=host -e DISPLAY=$${DISPLAY} -v $${HOME}/.Xauthority:/root/.Xauthority xeyes:0.1 xeyes
