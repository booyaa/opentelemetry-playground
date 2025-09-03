# Enabling tracing

We have a simple web API service with a single endpoint (/) that returns the number of times we have visited the endpoint. We use Redis to persist this, but also as a test to confirm traces contain spans for the web API service and Redis.

## Experiments

Rum the following shell scripts (hit CTRL+C to stop)

- standalone - Run the app with no wiring to Telemetry. Visiting `http://localhost:4567/` should display the following message, "Hello World! I have been seen N times". The number will increment everytime you visit.
- ruby-console - We configure our app's own console as an exporter
- otel-console - We configure our app to export to a local collector. Note: this work at the moment.
