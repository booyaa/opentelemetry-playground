# Hello Logs

In this experiment we try to ingest logs two different ways through a webhook and through a file receiver.

> :warning: We're about to start using the contrib version of the collector. If you're familar with Long Term Support (LTS) Linux distros you can think of the "core" collector in a similar manner. For the newer and experimental features will land in the "contrib" collector.

## Sending logs over HTTP

We'll set up our collector to have an incoming [webhook receiver][docs_webhook_rxr] to listen for log events.

To avoid adding complexity (observability backend like Datadog) to the collector we'll be using the [debug exporter][docs_debug_exp] to see the logs appear in the collector's console.

We'll be using two terminals. In terminal 1 start the environment `./webhook/start`

In terminal 2 we'll enter the environment and send a log entry

```sh
./shell
root@8e8954d75716:/#
# ^-- once in container run the following
wget -qO- http://localhost:4040/events --post-data "this is a random log entry number $RANDOM"
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

Wow that's a lot of text considering we just sent a single log line. By using the collector's [internal logger][docs_debug_exp_logger] our single log entry is transformed into a log record.

We can see there are a lot more fields added. If you search for "Body:" you'll see our log entry. Something you may have noticed is that time stamp appears to be Unix epoch time (midnight 1970-01-01). We can fix this by adding a processor to the collector or embed the timestamp in the log entry before sending it to the collector. We'll look at processors in a future experiment.

<!-- linkies -->
[docs_webhook_rxr]: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/webhookeventreceiver
[docs_debug_exp]: https://github.com/open-telemetry/opentelemetry-collector/blob/main/exporter/debugexporter/README.md
[docs_debug_exp_logger]: https://github.com/open-telemetry/opentelemetry-collector/blob/main/exporter/debugexporter/README.md#using-the-collectors-internal-logger
