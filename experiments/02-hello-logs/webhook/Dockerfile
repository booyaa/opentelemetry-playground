ARG OTEL_VERSION=0.117.0
ARG OTEL_PACKAGE_NAME=otelcol-contrib_${OTEL_VERSION}_linux_amd64.deb
ARG OTEL_URL=https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTEL_VERSION}/${OTEL_PACKAGE_NAME}
FROM debian:12.9-slim
ARG OTEL_URL
ARG OTEL_PACKAGE_NAME
ENV DEBIAN_FRONTEND=noninteractive
ENV OTEL_BINARY=/usr/bin/otelcol-contrib
RUN apt-get update
# RUN apt-get -y install wget
# RUN wget ${OTEL_URL}
# remove this before publishing ---v
RUN apt-get -y install curl
COPY otelcol-contrib_0.117.0_linux_amd64.deb .
# ^--- remove this before publishing
RUN dpkg -i ${OTEL_PACKAGE_NAME} || true
COPY config.yaml .
EXPOSE 4040
ENTRYPOINT ["sh","-c", "${OTEL_BINARY} --config config.yaml"]
