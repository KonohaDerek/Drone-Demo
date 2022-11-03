#!/bin/sh
# This script is used to build the project.
# It is assumed that the project is already configured.
# Run Docker build
docker build --build-arg GOOS=linux --build-arg GOARCH=amd64 --progress=plain -f Dockerfile -t skymirror/drone:nolimit . 