#!/bin/bash

# make sure to start LS with DOCKER_FLAGS='-e DNS_NAME_PATTERNS_TO_RESOLVE_UPSTREAM=snowflake-workshop-lab.s3.amazonaws.com'

npm install

sls deploy --stage local
