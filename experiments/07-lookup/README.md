# Enriching telemetry using lookups

Our goal is to enrich telemetry data with additional information from an external source, namely a CSV file. In this example we'll use the email address attribute as the look up field and enrich the log with additional attributes (Slack User ID and Coffee preference field). The [lookup](https://github.com/observIQ/bindplane-otel-collector/tree/main/processor/lookupprocessor) processor we'll be using isn't part of [contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main), but in later experiment we'll see how to build our own collector using the [OpenTelemtry Collector Builder](https://opentelemetry.io/docs/collector/custom-collector/) (OCB).

## Setup

Our CSV lookup file looks like this:

```csv
email,slack_user_id,likes_coffee
jane.bloggs@example.com,123456,yes
alice@example.com,100001,no
bob@example.com,100002,yes
```

The processor configuration looks like this:

```yaml
processors:
  lookup:
    csv: /etc/otel/lookup.csv # in relation to where the collector is
    context: attributes       # values: attributes, body, resource
    field: email              # must match the field in the CSV
```

Our log data looks something like this (edited for brievity):

```json
{
  "resourceLogs": [
    { ...
      "scopeLogs": [
        {
          "scope": { ... },
          "logRecords": [
            { ... },
              "attributes": [
                {
                  "key": "email",
                  "value": {
                    "stringValue": "jane.bloggs@example.com"
                  }
                }
              ]
...
```

## Running the experiment

```sh
# terminal 1
./start

# terminal 2
./send
```

You should see in the logs something similar to below (again edited for brievity):

```log
ResourceLog #0
  -> service.name: Str(my.service)
  ScopeLogs #0
      LogRecord #0
      Timestamp: 2018-12-13 14:51:00.3 +0000 UTC
      Attributes:
          -> email: Str(jane.bloggs@example.com)
          -> slack_user_id: Str(123456)
          -> likes_coffee: Str(yes)
```

We can see the log has been enriched with the Slack User ID and Coffee preference fields.
