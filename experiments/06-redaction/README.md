# Redacting sensitive information

Our goal is to remove or mask sensitive information. This is usually personally identifiable information (PII) such as names, addresses, phone numbers, email addresses, social security numbers, credit card numbers, etc.

Our examples will use three different processors:

- [Attributes](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/attributesprocessor)
- [Redaction](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/redactionprocessor)
- [Transform](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/transformprocessor)

They all have their strengths and weaknesses.

This experiment only processors for logs, but the other signals will follow.

The source for payloads can be found in [opentelemetry-proto](https://github.com/open-telemetry/opentelemetry-proto/blob/main/examples/README.md) repo.

## Attributes

```sh
# terminal 1
./start attributes

# terminal 2
./send logs.json
```

You should see in the logs something similar to below

```log
otelcollector  | Attributes:
otelcollector  |      -> string.attribute: Slice(["REDACTED"])
otelcollector  |      -> map.attribute: Map({"some.map.key":"REDACTED"})
otelcollector  |      -> int.attribute: Int(10)
otelcollector  |      -> double.attribute: Str(03440d14e5ed9aa22192fe31869635dbf10dd74c347c050e7e0303344f93ac5e)
otelcollector  |      -> array.attribute: Slice(["many","REDACTED"])
```

The config for the attribute processors looks like this

```yaml
processors:
  attributes:
    actions:
      - key: string.attribute
        value: [REDACTED]
        action: update
      - key: boolean.attribute
        action: delete
      - key: double.attribute
        action: hash
      - key: map.attribute # can't use hash on maps
        value: {"some.map.key":"REDACTED"}
        action: update
      - key: array.attribute # can't use hash on arrays
        value: ["many","REDACTED"]
        action: update
```

Observations

- We can only hash strings and numbers (which in turn are converted to strings)
- If you want to hash maps or arrays you need to rewrite the entire value
- Delete keys are excluded, that is to say that they will not be transferred to the next processor or exporter in the pipeline

## Redaction

```sh
# terminal 1
./start redaction
```

```sh
# terminal 2
./send logs-extra.json # this has attributes real life use cases
```

You should see in the logs something similar to below

```log
otelcollector  | Attributes:
otelcollector  |      -> metadata.visa: Str(****)
otelcollector  |      -> metadata.dob: Str(****)
otelcollector  |      -> metadata.email: Str(foo@example.com)
otelcollector  |      -> metadata.alt_email: Str(****)
otelcollector  |      -> redaction.masked.keys: Str(metadata.alt_email,metadata.dob,metadata.visa)
otelcollector  |      -> redaction.masked.count: Int(3)
otelcollector  |      -> redaction.allowed.keys: Str(metadata.email)
otelcollector  |      -> redaction.allowed.count: Int(1)
```

The config for the redaction processors looks like this

```yaml
processors:
  redaction:
    allow_all_keys: true # if this is false and no keys are listed in allowed_keys everything will be excluded
    # allowed_keys: # any key not listed here will be removed example
    #   - string.attribute
    #   - ...
    blocked_values: # these will be masked
      # - ".*" # this will block all values and convert to Str() (empty string) which is probably not what you wanted
      - "some string" # becomes Str(****)
      - "4[0-9]{12}(?:[0-9]{3})?" # visa card number
      - "[0-9]{4}-[0-9]{2}-[0-9]{2}" # YYYY-MM-DD date format
      - "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}" # email address
    allowed_values:
      - ".+@example.com" # will not mask metadata.email in logs-extra.json
    summary: debug # adds debugging stats to attributes
```

Observations

- We can easily block or hash attributes based on key or values
- We can also allow certain values to pass through even if there is a blanket block example.com email addresses are allowed
- Does require regex knowledge

## Transform

```sh
# terminal 1
./start transform
```

```sh
# terminal 2
./send logs-extra.json
```

You should see in the logs something similar to below

```log
otelcollector  | Attributes:
otelcollector  |      -> metadata.visa: Str(****)
otelcollector  |      -> metadata.dob: Str(2000-MM-DD)
otelcollector  |      -> metadata.email: Str(foo@example.com)
otelcollector  |      -> metadata.alt_email: Str(****)
```

The config for the transform processors looks like this

```yaml
processors:
  transform:
    log_statements:
      - context: log
        statements:
          - delete_key(attributes, "boolean.attribute") # explicit exclusion
          - replace_match(attributes["string.attribute"], "some string", "**** string")
          - replace_pattern(attributes["metadata.visa"], "4[0-9]{12}(?:[0-9]{3})?", "****") # redact visa card number
          - replace_pattern(attributes["metadata.dob"], "([0-9]{4})-[0-9]{2}-[0-9]{2}", "$1-MM-DD") # retain the year, but redact the rest of the date
          - set(attributes["metadata.alt_email"], "****") # redact alt_email
```

Observations

- Remove keys is easy
- Override values is easy
- Highly granular in scope
- Extensive range of function (this is a boon when you know what you're doing, but overwhelming when starting out)
- Multiple options for replace (all, match and pattern)
- Partial hash is supported if you under regex
