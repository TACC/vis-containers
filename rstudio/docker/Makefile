create:
	docker buildx create --platform linux/amd64,linux/ppc64le --use

buildx:
	docker buildx build --platform=linux/amd64,linux/ppc64le --tag wjallen/rstudio:1.4.1717 --push .

