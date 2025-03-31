FROM debian:12.9-slim
ENV OTEL_BINARY=/usr/bin/otelcol
COPY output/otelcolcustom ${OTEL_BINARY}
# COPY config.yaml .
# RUN ls /usr/bin/otel* &&
RUN chmod +x ${OTEL_BINARY}
ENTRYPOINT ["sh","-c", "${OTEL_BINARY} components"]
