#!/bin/sh

set -e

payload_file="payloads/$1"
if [ ! -f "$payload_file" ]; then
    echo "Error: $payload_file not found"
    exit 1
fi
echo "DEBUG: payload_file=$payload_file"

case "$payload_file" in
    *"logs"*)
        endpoint="logs"
        ;;
    *"metrics"*)
        endpoint="metrics"
        ;;
    *"traces"*)
        endpoint="traces"
        ;;
    *)
        echo "Error: unsupported endpoint"
        exit 1
        ;;
esac

curl -X POST -H "Content-Type: application/json" -d @"$payload_file" -i otelcollector:4318/v1/$endpoint
