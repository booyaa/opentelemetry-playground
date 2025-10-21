# Metrics scraping

We want to use the collector to scrap metrics and send them to a developer backend ([otel-tui][gh_oteltui]). We're generating metrics using the tried and tested [node exporter][gh_node_exporter] (which gets metrics from the host), but you could also use [telemetrygen][gh_telemetrygen].

## Experiment

Start up the containers

```sh
docker compose up -d
```

Let's check we can see metrics from the node-exporter

```sh
docker compose exec -it shell sh -c 'curl --silent http://node-exporter:9100/metrics' | grep promhttp_metric_handler_requests_total
# HELP promhttp_metric_handler_requests_total Total number of scrapes by HTTP status code.
# TYPE promhttp_metric_handler_requests_total counter
promhttp_metric_handler_requests_total{code="200"} 12
promhttp_metric_handler_requests_total{code="500"} 0
promhttp_metric_handler_requests_total{code="503"} 0
```

Attach to otel-tui

> [!INFO]
> We've remapped the detached command (default is `CTRL-P`,`CTRL-Q`) to `CTRL-A`, `D` to avoid problems if you're using VS Code.

```sh
docker compose attach --detach-keys "ctrl-a,d" oteltui
```

To use otel-tui to view metrics

- Press `Tab` to switch from `Traces` to `Metrics`
- To search for metric use `/` followed by the search term (example: `promhttp_metric_handler_requests_total`)
- You should be able to see details of the highlighted metrics (description, type, etc) as well as a spark graph
- To detach use keystrokes `CTRL-A`, `D`

Clean up

```sh
docker compose down --remove-orphans --volumes
```

<!-- links -->

[gh_node_exporter]: https://github.com/prometheus/node_exporter
[gh_telemetrygen]: https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/cmd/telemetrygen/README.md
[gh_oteltui]: https://github.com/ymtdzzz/otel-tui?tab=readme-ov-file
