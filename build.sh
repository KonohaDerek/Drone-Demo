#!/bin/sh
# This script is used to build the project.
# It is assumed that the project is already configured.
# Run Docker build
docker build --build-arg GOOS=linux --build-arg GOARCH=arm64 --progress=plain -f drone-nolimit.Dockerfile -t test/drone-nolimit . 