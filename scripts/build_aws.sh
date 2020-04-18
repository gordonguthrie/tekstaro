#!/bin/bash
# mebbies do some clean up
docker image rm tekstaro_release:0.1.0

set -e
set -o pipefail

# first build the dev image which makes the release
docker build -f ../docker/tekstaro.dockerfile -t tekstaro_release:0.1.0 .
# now build the aws release
docker build -f ../docker/aws.dockerfile -t tekstaro_aws:0.1.0 .
