# Hello World in OpenTelemetry

In this experiment we're going set up an environment to run the OpenTelemetry Collector manually. We'll use a simple configuration that does nothing (no operation). We'll also turn off any internal telemetry.

Tip: if you're using VS Code you can highlight the code snippets and use the command "Run Selection/Line in Active Terminal" to execute the commands.

Let's set up our test environment. We just need to install the tool "wget" to download the [collector][repo] package. Please refer to the the [Dockerfile][file_dockerfile] for the full details.

We run the collector using the command `/usr/bin/otelcol --config config.yaml`. We'll discuss the [config.yaml][file_config] file later on

Let's build our test environment in Docker

```sh
docker build --platform=linux/amd64 -t 01-hello-world .
```

Now run it

```sh
docker run --platform=linux/amd64 --name=01-hello-world --rm -it 01-hello-world
```

We should see something similar in our terminal

```log
2025-01-15T11:34:50.822Z        info    service@v0.117.0/service.go:164 Setting up own telemetry...
2025-01-15T11:34:50.823Z        info    service@v0.117.0/service.go:207 Skipped telemetry setup.
2025-01-15T11:34:50.830Z        info    service@v0.117.0/service.go:230 Starting otelcol-contrib...   {"Version": "0.117.0", "NumCPU": 2}
2025-01-15T11:34:50.830Z        info    extensions/extensions.go:39     Starting extensions...
2025-01-15T11:34:50.831Z        info    service@v0.117.0/service.go:253 Everything is ready. Begin running and processing data.
```

We can see the internal telemetry is disabled and the collector is ready to process data. Incidentally we know we're using 2 CPU cores (this matches how many CPU cores are allocated to my VM running Docker engine).

Let's review the config file to understand what's been configured.

For a working config, we need at least one receiver and one exporter. A useful component for both is the `nop`. This is short for "no operation". The [`nop` receiver][docs_nop_rxr] discards all data it receives and the [`nop` exporter][docs_nop_exp] does nothing with the data it receives.

```yaml
receivers:
  nop:

exporters:
  nop:
```

If you recall the output from the collector logs we could see that telemetry set up was skipped. Out of the box, the collector will generate it's own telemetry and at a minimum it exposes this as a prometheus metrics endpoint. To simplify this experiment we turned this off by setting the metrics level to none.

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
[file_dockerfile]: ./Dockerfile
[file_config]: ./config.yaml
[docs_nop_rxr]: https://github.com/open-telemetry/opentelemetry-collector/tree/main/receiver/nopreceiver
[docs_nop_exp]: https://github.com/open-telemetry/opentelemetry-collector/tree/main/exporter/nopexporter
[repo]: https://github.com/open-telemetry/opentelemetry-collector-releases/releases
