#!/bin/bash

export AWS_DEFAULT_REGION=eu-west-2 AWS_ACCESS_KEY_ID=localstack_access_key AWS_SECRET_ACCESS_KEY=localstack_secret_key
env
awslocal s3 mb s3://"$OTEL_BUCKET"
