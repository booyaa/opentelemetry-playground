FROM golang:1.24.2-bookworm AS build
WORKDIR /build
COPY custom-builder-config.yaml .
RUN go install go.opentelemetry.io/collector/cmd/builder@v0.122.1
RUN CGO_ENABLED=0 builder --config=custom-builder-config.yaml

FROM cgr.dev/chainguard/static:latest
COPY --from=build /build/otelcolcustom /
COPY config.yaml /
EXPOSE 4317/tcp 4318/tcp 13133/tcp
CMD ["/otelcolcustom", "components"]
