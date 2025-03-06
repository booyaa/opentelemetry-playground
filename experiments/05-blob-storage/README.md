# Storing telemetry in blob storage

Our goal for this experiment is to store our telemetry data in blob storage, in this case we'll be using AWS S3. This is a common scenario to avoid incurring large storage costs if you send all the data to an observability backend like Datadog, New Relic, or Honeycomb.

This experiment has a few moving parts:

- Instead of manually generating telemetry data we'll use [telemetrygen][link_telemetrygen] which is the standard testing tool for the OpenTelemetry Collector.
- We'll use the [AWS s3][link_s3_exporter] OpenTelemetry exporter to store telemetry data in a blob storage.
- Finally simulate AWS S3 (Amazon Web Service's Blob storage service) using [LocalStack][link_localstack] to simulate the AWS S3. S3 API is used by a lot of Cloud Services and tools.

We're going to assume that the container run time you're using is Docker compatible (moby) and the client has the "compose" command.

Let's start up the services

```sh
docker compose up # you may need to run this twice if the first time fails
```

After running for a short while we should see the localstack service return something similar to this

```log
localstack-main  | make_bucket: otel-collector
localstack-main  | Ready.
```

If you spotted the following message, then the OpenTelemetry Collector was able to store the telemetry on the s3 bucket

```log
localstack-main  | 2025-03-06T11:53:01.043  INFO --- [et.reactor-0] localstack.request.aws     : AWS s3.PutObject => 200
```

Let's example the data that was stored in the s3 bucket. Shell into the awscli service.

```sh
docker compose exec awscli sh
```

Let's find our file

```sh
telemetry_file=$(aws s3 ls s3://$OTEL_BUCKET --recursive | awk '{print $4}' | head -1)
aws s3 cp s3://$OTEL_BUCKET/$telemetry_file -
# you should see something similar
{"resourceMetrics":[{"resource":{},"scopeMetrics":[{"scope":{},"metrics":[{"name":"gen","gauge":{"dataPoints":[{"timeUnixNano":"1741263244284223860","asInt":"0"}]}}]}],"schemaUrl":"https://opentelemetry.io/schemas/1.13.0"}]}
```

## OpenTelemetry Collector Config

Make sure your telemetrygen service match this endpoint

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
```

Using LocalStack means we have to override a few default settings like `disable_ssl` and `s3_force_path_style`. We also need to set the `endpoint` to the LocalStack service. We wouldn't normally need to do this in a real AWS environment.

```yaml
exporters:
    awss3/metrics:
        s3uploader:
        region: ${env:AWS_REGION}
        s3_bucket: ${env:OTEL_BUCKET}
        s3_prefix: metrics
        disable_ssl: true
        endpoint: ${env:AWS_ENDPOINT_URL}
        s3_force_path_style: true
```

Finally wire up our exporter to the pipeline

```yaml
service:
  pipelines:
    metrics:
      receivers: [otlp]
      exporters: [awss3/metrics]
```

<!-- links -->
[link_telemetrygen]: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/cmd/telemetrygen
[link_s3_exporter]: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/awss3exporter
[link_localstack]: https://www.localstack.cloud/
