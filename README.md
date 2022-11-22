[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/inalogy)](https://artifacthub.io/packages/search?repo=inalogy)
[![CD Pipeline](https://github.com/inalogy/charts/actions/workflows/cd-pipeline.yml/badge.svg)](https://github.com/inalogy/charts/actions/workflows/cd-pipeline.yml)

# The Inalogy Library for Kubernetes

Popular applications, provided by [Inalogy](https://inalogy.com), ready to launch on Kubernetes using [Kubernetes Helm](https://github.com/helm/helm).

## TL;DR

```bash
$ helm repo add inalogy https://charts.inalogy.com/inalogy
$ helm search repo inalogy
$ helm install my-release inalogy/<chart>
```

## Vulnerabilities scanner

Each Helm chart contains one or more containers. Those containers use images provided by Inalogy through its test & release pipeline and whose source code can be found at [inalogy/containers](https://github.com/inalogy/containers).

As part of the container releases, the images are scanned for vulnerabilities, [here](https://github.com/inalogy/containers#vulnerability-scan-in-inalogy-container-images) you can find more info about this topic.

Since the container image is an immutable artifact that is already analyzed, as part of the Helm chart release process we are not looking for vulnerabilities in the containers but running different verification to ensure the Helm charts work as expected, see the testing strategy defined at [_TESTING.md_](https://github.com/inalogy/charts/blob/main/TESTING.md).

## Before you begin

### Prerequisites

- Kubernetes 1.22+
- Helm 3.2.0+

### Setup a Kubernetes Cluster

For setting up Kubernetes on other cloud platforms or bare-metal servers refer to the Kubernetes [getting started guide](https://kubernetes.io/docs/getting-started-guides/).

### Install Helm

Helm is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources.

To install Helm, refer to the [Helm install guide](https://github.com/helm/helm#install) and ensure that the `helm` binary is in the `PATH` of your shell.

### Add Repo

The following command allows you to download and install all the charts from this repository:

```bash
$ helm repo add inalogy https://charts.inalogy.com/inalogy
```

### Using Helm

Once you have installed the Helm client, you can deploy a Inalogy Helm Chart into a Kubernetes cluster.

Please refer to the [Quick Start guide](https://helm.sh/docs/intro/quickstart/) if you wish to get running in just a few commands, otherwise the [Using Helm Guide](https://helm.sh/docs/intro/using_helm/) provides detailed instructions on how to use the Helm client to manage packages on your Kubernetes cluster.

Useful Helm Client Commands:
* View available charts: `helm search repo`
* Install a chart: `helm install my-release inalogy/<package-name>`
* Upgrade your application: `helm upgrade`

## License

Copyright &copy; 2022 Inalogy

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
