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
    docker run --platform=linux/amd64 --name=playground --network=host --rm -it -p 4040:4040 02-logs-http
```

```sh
# terminal 2
curl -4 http://localhost:4040/events -d "this is a random log entry number $RANDOM"
```

We should see something similar in our console

```log
2025-01-15T17:09:31.677Z        info    Logs    {"kind": "exporter", "data_type": "logs", "name": "debug", "resource logs": 1, "log records": 1}
2025-01-15T17:09:31.677Z        info    ResourceLog #0
Resource SchemaURL:
ScopeLogs #0
ScopeLogs SchemaURL:
InstrumentationScope otlp/webhookevent 0.117.0
InstrumentationScope attributes:
     -> source: Str(webhookevent/curl)
     -> receiver: Str(webhookevent)
LogRecord #0
ObservedTimestamp: 2025-01-15 17:09:31.677284784 +0000 UTC
Timestamp: 1970-01-01 00:00:00 +0000 UTC
SeverityText:
SeverityNumber: Unspecified(0)
Body: Str(this is a random log entry number 19229)
Trace ID:
Span ID:
Flags: 0
        {"kind": "exporter", "data_type": "logs", "name": "debug"}
```

There's a lot of text, by using the collector's internal logger our single log entry is transformed into a log record. We can see there are a lot more fields added. If you search for "Body:" you'll see our log entry. Something you may have noticed is that time stamp appears to be Unix epoch time (midnight 1970-01-01). We can fix this by adding a processor to the collector or embed the timestamp in the log entry before sending it to the collector. We'll look at processors in another future experiment.
