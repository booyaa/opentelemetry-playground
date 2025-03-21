# opentelemetry-playground

A playground environment to experiment (initially) with the OpenTelemetry Collector.

## Introduction

OpenTelemetry is a collection of tools, APIs, and SDKs used to instrument, generate, collect, and export telemetry data (metrics, logs, and traces) for analysis in order to understand your software's performance and behavior.

This playground will focus initially on the Collector which is a high-performance, vendor-agnostic agent that can receive, process, and export telemetry data.

Each sub-directory in this repository will contain a different experiment with the OpenTelemetry Collector.

## Pre-requisites

You will need a Linux or MacOS environment with the following tools installed:

- Bourne Again Shell (BASH) (where possible I will try to make the scripts Z shell compatible)
- [Rancher Desktop][www_rancher] or any other engine using the containerd container runtime.
- [Helm][www_helm]
- [kubectl][www_kubectl]

Notes

- Windows users can use WSL2 to run the above tools (you may find Docker Desktop easier configure within your WSL instances).
- MacOS users you will to enable rosetta as we'll be using linux/amd64 images.
- It's highly recommend you use some form of isolation for your experiments such as Virtual Machine or NixOS to avoid affecting your main development environment.
- Avoid running these on work computer you may find something on the computer (Netskope, ZScaler, etc) will block network traffic and give you unexpected behaviour.

## Experiments

- [01 - Hello world!][exp_001]
- [02 - Hello logs][exp_002]
- [03 - StatsD to JSON][exp_003]
- [04 - Fluent Bit/Fluent D][exp_004]
- [05 - Storing telemetry in blob storage][exp_005]
- [06 - Redacting sensitive information][exp_006]
- [07 - Enriching telemetry using lookups][exp_007]
---

Mark Sta Ana Copyright 2025

<!-- linkies -->
[exp_001]: ./experiments/01-hello-world/README.md
[exp_002]: ./experiments/02-hello-logs/README.md
[exp_003]: ./experiments/03-statsd-to-json/README.md
[exp_004]: ./experiments/04-fluent/README.md
[exp_005]: ./experiments/05-blob-storage/README.md
[exp_006]: ./experiments/06-redaction/README.md
[exp_007]: ./experiments/07-lookup/README.md
[www_rancher]: https://rancherdesktop.io/
[www_helm]: https://helm.sh/
[www_kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
