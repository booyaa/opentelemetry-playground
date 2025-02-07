# Fluent to OpenTelemetry

## Fluent Bit

We're using the dummy input to generate log messages for the OpenTelemetry 
Collector. The log message is a very simple JSON payload

```json
{
  "top": {
    ".dotted": "value"
  }
}
```

When we run `./fluent-bit/start` we should see the following console entry in 
the Collector:

```log
LogRecord #0
ObservedTimestamp: 1970-01-01 00:00:00 +0000 UTC
Timestamp: 2025-02-06 10:49:44.135758496 +0000 UTC
SeverityText: 
SeverityNumber: Unspecified(0)
Body: Map({"top":{".dotted":"value"}})
Trace ID: 
Span ID: 
Flags: 0
```

You can stop the demo by using CTRL-C or running `./fluent-bit/stop` in another 
terminal session.

## fluentd

fluentd also has a similar input to generate test message. Unfortunately there's 
no out of the box way to send data from fluentd as OTLP. Instead we have to 
utilise fluentd's forward protocol. Luckily you'll find a forward receiver in 
the "contrib" version of the Collector.

When we run `./fluentd/start` we should see the following console entry in 
the Collector:

```log
fluentd-1  | 2025-02-07 10:12:47.063832341 +0000 dummy: {"hello":"world","widgets":0}
otel-collector-1  | 2025-02-07T10:12:48.580Z    info    Logs    {"kind": "exporter", "data_type": "logs", "name": "debug", "resource logs": 1, "log records": 2}
otel-collector-1  | 2025-02-07T10:12:48.580Z    info    ResourceLog #0
otel-collector-1  | Resource SchemaURL: 
otel-collector-1  | ScopeLogs #0
otel-collector-1  | ScopeLogs SchemaURL: 
otel-collector-1  | InstrumentationScope  
otel-collector-1  | LogRecord #0
otel-collector-1  | ObservedTimestamp: 1970-01-01 00:00:00 +0000 UTC
otel-collector-1  | Timestamp: 2025-02-07 10:12:47.063832341 +0000 UTC
otel-collector-1  | SeverityText: 
otel-collector-1  | SeverityNumber: Unspecified(0)
otel-collector-1  | Body: Empty()
otel-collector-1  | Attributes:
otel-collector-1  |      -> hello: Str(world)
otel-collector-1  |      -> widgets: Int(0)
otel-collector-1  |      -> fluent.tag: Str(dummy)
otel-collector-1  | Trace ID: 
otel-collector-1  | Span ID: 
otel-collector-1  | Flags: 0
```

We can see the test message appear in fluentd's console and then after fluentd's
buffered logs have been flushed the logs will appear in the Collector.