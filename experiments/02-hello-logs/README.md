# Hello Logs

In this experiment we try to ingest logs two different ways through a webhook and through a file receiver.

:warning: We're about to start using the contrib version of the collector. If you're familar with long term support Linux distros you can think of the "core" collector in a similar manner. For the newer and experimental features will land in the "contrib" collector.

## Sending logs over HTTP

We'll set up our collector to have an incoming webhook to listen for log events.

To avoid adding complexity (observability backend like Datadog) to the collector we'll be using the debug exporter to see the logs appear in the collector's console.

We'll be using two terminals

```sh
# terminal 1
docker build --platform=linux/amd64 -t 02-logs-http ./webhook && \
docker run --platform=linux/amd64 --name=playground --rm -it -p 4040:4040 02-logs-http
```

```sh
# terminal 2
docker exec -it playground curl http://localhost:4040/events -d "random log line $RANDOM"
```
