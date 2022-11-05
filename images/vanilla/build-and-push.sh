#!/bin/bash
# shellcheck disable=SC2013

image=${DOCKER_USER:-adaliszk}/valheim-server

echo "Building $image..."
docker build . -t "$image"

for tag in $(cat Dockertag); do
  echo "Tagging $image:$tag"
  docker tag "$image" "$image:$tag"
done

for tag in $(cat Dockertag); do
  echo "Pushing $image:$tag"
  docker push "$image:$tag"
done
