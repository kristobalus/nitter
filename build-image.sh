#!/bin/bash

# Read the version from package.json
VERSION=1.0.4
IMAGE=kristobalus/nitter
echo "building image $IMAGE using buildx for multi-arch..."

docker buildx create --use --name buildx_instance --driver docker-container --bootstrap
docker buildx build -f ./Dockerfile \
		--progress=plain \
		--build-arg VERSION="$VERSION" \
		--label "build-tag=build-artifact" \
		--platform linux/amd64 \
		-t $IMAGE:$VERSION \
		--push . || { echo "failed to build docker image"; exit 1; }

# commented out to keep cached layers
# docker buildx rm buildx_instance
docker tag $IMAGE:$VERSION $IMAGE:latest
docker push $IMAGE:latest
docker image prune -f --filter label=build-tag=build-artifact
