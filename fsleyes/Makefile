build:
	docker build -t fsleyes:1.4.5 .

run:
	docker run -e DISPLAY=host.docker.internal:0 fsleyes:1.4.5 fsleyes

run-remote:
	docker run --rm --net=host -e DISPLAY=$${DISPLAY} -v $${HOME}/.Xauthority:/root/.Xauthority fsleyes:1.4.5 fsleyes

