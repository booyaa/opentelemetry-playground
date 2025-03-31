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

Let's review the ocb logs, we can see our volume mapped manifest was used. Also we can see the built binary's file path.

```log
ocb-1 | internal/command.go:99  OpenTelemetry Collector Builder {"version": "0.122.1"}
ocb-1 | internal/command.go:104 Using config file       {"path": "/build/builder-config.yaml"}
ocb-1 | builder/config.go:165   Using go        {"go-executable": "/usr/local/go/bin/go"}
ocb-1 | builder/main.go:99      Sources created {"path": "/build"}
ocb-1 | builder/main.go:201     Getting go modules
ocb-1 | builder/main.go:110     Compiling
ocb-1 | builder/main.go:140     Compiled        {"binary": "/build/otelcolcustom"}
```

We can see in the opentelemetry collector logs (edited for brevity) that the lookup processor is part of our build.

```log
otel-collector-1  | buildinfo:
otel-collector-1  |     command: otelcolcustom
otel-collector-1  |     description: OpenTelemetry Collector
otel-collector-1  |     version: 0.122.1
otel-collector-1  | receivers: []
otel-collector-1  | processors:
otel-collector-1  |     - name: lookup
otel-collector-1  |       module: github.com/observiq/bindplane-otel-collector/processor/lookupprocessor v1.73.1
otel-collector-1  |       stability:
otel-collector-1  |         logs: Alpha
otel-collector-1  |         metrics: Alpha
otel-collector-1  |         traces: Alpha
```

<!-- links -->
[gh_ocb]: https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder
[gh_ocb_manifest]: https://github.com/open-telemetry/opentelemetry-collector-releases/blob/main/distributions/otelcol-contrib/manifest.yaml
