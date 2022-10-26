#!/bin/sh

for image_hash in $(docker images | grep "^<none>" | awk '{print $3}'); do
    docker rmi $image_hash
done
