# Hello World in OpenTelemetry

In this experiment we're going set up an environment to run the OpenTelemetry Collector manually. We'll use a simple configuration that does nothing (no operation). We'll also turn off any internal telemetry.

Tip: if you're using VS Code you can highlight the code snippets and use the command "Run Selection/Line in Active Terminal" to execute the commands.

Let's set up our test environment. We just need to install the tool "wget" to download the [collector][repo] package. Please refer to the the [Dockerfile][file_dockerfile] for the full details.

We run the collector using the command `/usr/bin/otelcol --config config.yaml`. We'll discuss the [config.yaml][file_config] file later on

Let's build and run our test environment in Docker: `./start`

We should see something similar in our terminal

```log
2025-01-15T11:34:50.822Z        info    service@v0.117.0/service.go:164 Setting up own telemetry...
2025-01-15T11:34:50.823Z        info    service@v0.117.0/service.go:207 Skipped telemetry setup.
2025-01-15T11:34:50.830Z        info    service@v0.117.0/service.go:230 Starting otelcol-contrib...   {"Version": "0.117.0", "NumCPU": 2}
2025-01-15T11:34:50.830Z        info    extensions/extensions.go:39     Starting extensions...
2025-01-15T11:34:50.831Z        info    service@v0.117.0/service.go:253 Everything is ready. Begin running and processing data.
```

Our "Hello, World!" in this case is this log message "Everything is ready. Begin running and processing data.". Congratulations we've created a working OpenTelemetry Collector environment. Not a very useful one, but it's a good start. You can stop the collector by pressing `Ctrl+C`.

We can see the internal telemetry is disabled and the collector is ready to process data.

Let's review the config file to understand what's been configured.

For a working config, we need at least one receiver and one exporter. A useful component for both is the `nop`, this is short for "no operation". The [`nop` receiver][docs_nop_rxr] discards all data it receives and the [`nop` exporter][docs_nop_exp] does nothing with the data it receives.

```yaml
receivers:
  nop:

exporters:
  nop:
```

If you recall the output from the collector logs we could see that internal telemetry was skipped.

```log
2025-01-16T08:08:02.979Z        info    service@v0.117.0/service.go:207 Skipped telemetry setup.
```

The default for the collector generates own telemetry (specifically metrics, logs and traces are handled differently) as [Prometheus endpoint][docs_prometheus_endpoint]. To simplify this experiment we turned this off by setting the metrics level to none. We'll review this feature in a later experiment.

```yaml
service:
  telemetry:
    metrics:
      level: none
```

Finally we need a way to connect the receiver and exporter together. This is done through a pipeline. As the name implies we can do some processing in between the receiver and exporter, something we'll look at later on.

```yaml
  pipelines:
    logs:
      receivers: [nop]
      exporters: [nop]
```

<!-- linkies -->
[docs_nop_exp]: https://github.com/open-telemetry/opentelemetry-collector/tree/main/exporter/nopexporter
[docs_nop_rxr]: https://github.com/open-telemetry/opentelemetry-collector/tree/main/receiver/nopreceiver
[docs_prometheus_endpoint]: https://opentelemetry.io/docs/collector/internal-telemetry/#configure-internal-metrics
[file_config]: ./config.yaml
[file_dockerfile]: ./Dockerfile
[repo]: https://github.com/open-telemetry/opentelemetry-collector-releases/releases
