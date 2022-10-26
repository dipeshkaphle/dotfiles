#!/bin/sh
for name in $( docker ps -a | awk '{print $NF}' | tail -n +2 ); do
    docker rm $name
done

