# Enabling tracing

We have a simple web API service with a single endpoint (/) that returns the number of times we have visited the endpoint. We use Redis to persist this, but also as a test to confirm traces contain spans for the web API service and Redis.

## Experiments

Rum the following shell scripts (hit CTRL+C to stop)

- standalone - Run the app with no wiring to Telemetry. Visiting `http://localhost:4567/` should display the following message, "Hello World! I have been seen N times". The number will increment everytime you visit.
- ruby-console - We configure our app's own console as an exporter
- otel-console - We configure our app to export to a local collector (debug), we've also enabled [zipkin](https://zipkin.io/) and [jaeger](https://www.jaegertracing.io/docs/2.10/getting-started/) to visualise traces.

> [!TIP]
> Even if the web app isn't hooked to OpenTelemetry by enter the web container sending a test trace using `./send-test-trace` in another terminal
