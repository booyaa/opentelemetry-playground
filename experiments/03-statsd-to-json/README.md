# StatsD to JSON

In this experiment we spin up a [StatsD][www_statsd] server ([receiver][docs_statsd_rxr]) and write the metrics to a [file][docs_file_exp] (exporter) in JSON format.

> :warning: We're about to start using the contrib version of the collector. If you're familar with Long Term Support (LTS) Linux distros you can think of the "core" collector in a similar manner. For the newer and experimental features will land in the "contrib" collector.

We'll be using two terminals. In terminal 1 start the environment `./start`

In terminal 2 we'll enter the environment, send some test metrics and then check the log file for output.

```sh
./shell
root@8e8954d75716:/#
# ^-- once in container
# run the following --v
# generate a counter metric
echo "test.metric:$RANDOM|c|#myKey:myVal" | nc -w 1 -u localhost 8125;
# check the contents of the log file
tail -f /var/log/statsd.log
```

We should see something similar in our log file (I've formatted it for readability)

```json
{
    "resourceMetrics": [
        {
            "resource": {},
            "scopeMetrics": [
                {
                    "scope": {
                        "name": "github.com/open-telemetry/opentelemetry-collector-contrib/receiver/statsdreceiver",
                        "version": "0.117.0"
                    },
                    "metrics": [
                        {
                            "name": "test.metric",
                            "sum": {
                                "dataPoints": [
                                    {
                                        "attributes": [
                                            {
                                                "key": "myKey",
                                                "value": {
                                                    "stringValue": "myVal"
                                                }
                                            }
                                        ],
                                        "startTimeUnixNano": "1737047135002480107",
                                        "timeUnixNano": "1737047195000791302",
                                        "asInt": "22303"
                                    }
                                ],
                                "aggregationTemporality": 1
                            }
                        }
                    ]
                }
            ]
        }
    ]
}
```

For the opentelemetry config file we used the defaults for the StatsD receiver (specifically listen localhost on port 8125).

```yaml
receivers:
  statsd:
```

For the file expoter we just specify the path where we want to create the logs, by default the data is written in JSON format.

```yaml
exporters:
  file:
    path: /var/log/statsd.log
```

The only item of note is that we're linking this to the metrics pipeline (which makes sense given the nature of the StatsD receiver)

```yaml
service:
  pipelines:
    metrics:
      receivers: [statsd]
      exporters: [file]
```

<!-- linkies -->
[docs_statsd_rxr]: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/statsdreceiver
[docs_file_exp]: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/fileexporter
[www_statsd]: https://github.com/statsd/statsd?tab=readme-ov-file#usage
