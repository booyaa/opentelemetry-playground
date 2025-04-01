# How to build you own custom OpenTelemetry Collector

In this experiment, we'll build our own custom OpenTelemetry Collector using the builder tool ([ocb][gh_ocb]). This
tool uses a manifest to define the components to be included in the collector. This experiment will use a paired down
manifest which will demonstrate the compilation of required components and collector will be run to validate the
required components are loaded using the OpenTelemetry Collector `components` command.

That said, if you want a good starting point to build fully functioning collector then use the "contrib" collector
builder [manifest][gh_ocb_manifest] as a base.

Let's review the ocb manifest

```yaml
dist:
  module: github.com/open-telemetry/opentelemetry-collector-releases/core
  name: otelcolcustom
  description: OpenTelemetry Collector
  version: 0.122.1
  output_path: /build

processors:
  - gomod: github.com/observiq/bindplane-otel-collector/processor/lookupprocessor v1.73.1
```

The items to note are:

- We're using the [lookup](https://github.com/observIQ/bindplane-otel-collector/tree/main/processor/lookupprocessor) processor from experiment [7](../07-lookup/README.md). To find the correct version, go to the repo's releases page. Alternatively you can use "go get" to pull down the latest version of the module and inspect the go.mod file.
- dist.name is the name of your collector binary.
- dist.output_path is the location where the collector binary will be built. This is a volume mount in the docker container to allow easy reference for the collector image.

```sh
./start
```

Previously we used docker compose to build our collector, but since moving to a multi-stage build the logging output
has changed. To see what is happening to the build process we need to the build command separately.

We can see our custom manifest was used. Also we can see the built binary's file path.

```sh
docker build --no-cache --progress=plain -t ocb-multi .
# a lot of the output has been trimmed for brevity, we're only interested in what the builder is doing
#11 [build 5/5] RUN CGO_ENABLED=0 builder --config=custom-builder-config.yaml
#11 0.381 2025-04-01T13:55:15.602Z      INFO    internal/command.go:99  OpenTelemetry Collector Builder {"version": "v0.123.0"}
#11 0.381 2025-04-01T13:55:15.602Z      INFO    internal/command.go:104 Using config file       {"path": "custom-builder-config.yaml"}
#11 0.381 2025-04-01T13:55:15.603Z      INFO    builder/config.go:160   Using go        {"go-executable": "/usr/local/go/bin/go"}
#11 0.382 2025-04-01T13:55:15.603Z      INFO    builder/main.go:99      Sources created {"path": "/build"}
#11 87.31 2025-04-01T13:56:42.532Z      INFO    builder/main.go:201     Getting go modules
#11 94.24 2025-04-01T13:56:49.461Z      INFO    builder/main.go:110     Compiling
#11 171.0 2025-04-01T13:58:06.209Z      INFO    builder/main.go:140     Compiled        {"binary": "/build/otelcolcustom"}
#11 DONE 171.9s
```

We can see in the opentelemetry collector logs that the lookup processor is part of our build. Also
we can see someone (me) has snuck in the Datadog [exporter][otel_datadog_exporter]. Warning: if this Dockerfile file
fails to build for you on a non-Linux platform you maybe need to increase your VM's memory limit it can vary between
8-10 GB depending on your container runtime. Alternatively comment out the Datadog exporter and try again.

```log
buildinfo:
    command: otelcolcustom
    description: OpenTelemetry Collector
    version: 0.122.1
receivers: []
processors:
    - name: lookup
      module: github.com/observiq/bindplane-otel-collector/processor/lookupprocessor v1.73.1
      stability:
        logs: Alpha
        metrics: Alpha
        traces: Alpha
exporters:
    - name: datadog
      module: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datadogexporter v0.123.0
      stability:
        logs: Beta
        metrics: Beta
        traces: Beta
connectors: []
extensions: []
providers:
    - scheme: https
      module: go.opentelemetry.io/collector/confmap/provider/httpsprovider v1.29.0
    - scheme: yaml
      module: go.opentelemetry.io/collector/confmap/provider/yamlprovider v1.29.0
    - scheme: env
      module: go.opentelemetry.io/collector/confmap/provider/envprovider v1.29.0
    - scheme: file
      module: go.opentelemetry.io/collector/confmap/provider/fileprovider v1.29.0
    - scheme: http
      module: go.opentelemetry.io/collector/confmap/provider/httpprovider v1.29.0
```

<!-- links -->
[gh_ocb]: https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder
[gh_ocb_manifest]: https://github.com/open-telemetry/opentelemetry-collector-releases/blob/main/distributions/otelcol-contrib/manifest.yaml
[otel_datadog_exporter]: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/datadogexporter
