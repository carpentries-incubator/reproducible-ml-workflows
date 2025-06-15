---
title: "Using Pixi environments on HTC Systems"
teaching: 60
exercises: 30
---

::: questions

* How can you run workflows that use GPUs with Pixi CUDA environments?
* What solutions exist for the resources you have?

:::

::: objectives

* Learn how to submit containerized workflows to HTC systems.

:::

## High Throughput Computing (HTC)

One of the most common forms of production computing is **high-throughput computing (HTC)**, where computational problems as distributed across multiple computing resources to parallelize computations and reduce total compute time.
HTC resources are quite dynamic, but usually focus on smaller memory and disk requirements on each individual worker compute node.
This is in contrast to **high-performance computing (HPC)** where there are comparatively fewer compute nodes but the capabilities and associated memory, disk, and bandwidth resources are much higher.

Two of the most common HTC workflow management systems are [HTCondor](https://htcondor.org/) and [SLURM](https://slurm.schedmd.com/).

## Setting up a problem

First let's create a computing problem to apply these compute systems to.

Let's first create a new project in our Git repository

```bash
pixi init ~/pixi-lesson/htcondor
cd ~/pixi-lesson/htcondor
```
```output
✔ Created ~/<username>/pixi-lesson/htcondor/pixi.toml
```

### Training a PyTorch model on the MNIST dataset

Let's write a very standard tutorial example of training a deep neral network on the [MNIST dataset](https://en.wikipedia.org/wiki/MNIST_database) with PyTorch and then run it on GPUs in an HTCondor worker pool.

::: caution

## Mea culpa, more interesting examples exist

More exciting examples will be used in the future, but MNIST is perhaps one of the most simple examples to illustrate a point.

:::

#### The neural network code

We'll download Python code that uses a convocational neural network written in PyTorch to learn to identify the handwritten number of the MNIST dataset and place it under a `src/` directory.
This is a modified example from the PyTorch documentation (https://github.com/pytorch/examples/blob/main/mnist/main.py) which is [licensed under the BSD 3-Clause license](https://github.com/pytorch/examples/blob/abfa4f9cc4379de12f6c340538ef9a697332cccb/LICENSE).

```bash
curl -sLO https://raw.githubusercontent.com/matthewfeickert/nvidia-gpu-ml-library-test/a270442b3b910398a25e9a41e26e3c0c93f50e0f/torch_MNIST.py
mkdir -p src
mv torch_MNIST.py src/
```

#### The Pixi environment

Now let's think about what we need to use this code.
Looking at the imports of `src/torch_MNIST.py` we can see that `torch` and `torchvision` are the only imported libraries that aren't part of the Python standard library, so we will need to depend on PyTorch and `torchvision`.
We also know that we'd like to use CUDA accelerated code, so that we'll need CUDA libraries and versions of PyTorch that support CUDA.

::: challenge

## Create the environment

Create a Pixi workspace that:

* Has PyTorch and `torchvision` in it.
* Has the ability to support CUDA v12.
* Has an environment that has the CPU version of PyTorch and `torchvision` that can be installed on `linux-64`, `osx-arm64`, and `win-64`.
* Has an environment that has the GPU version of PyTorch and `torchvision`.

::: solution

This is just expanding the exercises from the CUDA conda packages episode.

Let's first add all the platforms we want to work with to the workspace

```bash
pixi workspace platform add linux-64 osx-arm64 win-64
```
```output
✔ Added linux-64
✔ Added osx-arm64
✔ Added win-64
```

We know that in both environment we'll want to use Python, and so we can install that in the `default` environment and have it be used in both the `cpu` and `gpu` environment.

```bash
pixi add python
```
```output
✔ Added python >=3.13.5,<3.14
```

Let's now add the CPU requirements to a feature named `cpu`

```bash
pixi add --feature cpu pytorch-cpu torchvision
```
```output
✔ Added pytorch-cpu
✔ Added torchvision
Added these only for feature: cpu
```

and then create an environment named `cpu` with that feature

```bash
pixi workspace environment add --feature cpu cpu
```
```output
✔ Added environment cpu
```

and insatiate it with particular versions

```bash
pixi upgrade --feature cpu
```

```toml
[workspace]
channels = ["conda-forge"]
name = "htcondor"
platforms = ["linux-64", "osx-arm64", "win-64"]
version = "0.1.0"

[tasks]

[dependencies]
python = ">=3.13.5,<3.14"

[feature.cpu.dependencies]
pytorch-cpu = ">=2.7.0,<3"
torchvision = ">=0.22.0,<0.23"

[environments]
cpu = ["cpu"]
```

Now let's add the GPU environment and dependencies.
Let's start with the CUDA system requirements

```bash
pixi workspace system-requirements add --feature gpu cuda 12
```

::: caution

## Override the `__cuda` virtual package

Remember that if you're on a platform that doesn't support the `system-requirement` you'll need to override the checks to solve the environment.

```bash
export CONDA_OVERRIDE_CUDA=12
```

:::

and create an environment from the feature

```bash
pixi workspace environment add --feature gpu gpu
```
```output
✔ Added environment gpu
```

and then add the GPU dependencies for the target platform of `linux-64` (where we'll run in production).

```bash
pixi add --platform linux-64 --feature gpu pytorch-gpu torchvision
```
```output
✔ Added pytorch-gpu >=2.7.0,<3
✔ Added torchvision >=0.22.0,<0.23
Added these only for platform(s): linux-64
Added these only for feature: gpu
```

```toml
[workspace]
channels = ["conda-forge"]
name = "htcondor"
platforms = ["linux-64", "osx-arm64", "win-64"]
version = "0.1.0"

[tasks]

[dependencies]
python = ">=3.13.5,<3.14"

[feature.cpu.dependencies]
pytorch-cpu = ">=2.7.0,<3"
torchvision = ">=0.22.0,<0.23"

[feature.gpu.system-requirements]
cuda = "12"

[feature.gpu.target.linux-64.dependencies]
pytorch-gpu = ">=2.7.0,<3"
torchvision = ">=0.22.0,<0.23"

[environments]
cpu = ["cpu"]
gpu = ["gpu"]
```

:::
:::

To validate that things are working with the CPU code, let's do a short training run for only `2` epochs in the `cpu` environment.

```bash
pixi run --environment cpu python src/torch_MNIST.py --epochs 2 --save-model --data-dir data
```
```output
100.0%
100.0%
100.0%
100.0%
Train Epoch: 1 [0/60000 (0%)]	Loss: 2.329474
Train Epoch: 1 [640/60000 (1%)]	Loss: 1.425185
Train Epoch: 1 [1280/60000 (2%)]	Loss: 0.826808
Train Epoch: 1 [1920/60000 (3%)]	Loss: 0.556883
Train Epoch: 1 [2560/60000 (4%)]	Loss: 0.483756
...
Train Epoch: 2 [57600/60000 (96%)]	Loss: 0.146226
Train Epoch: 2 [58240/60000 (97%)]	Loss: 0.016065
Train Epoch: 2 [58880/60000 (98%)]	Loss: 0.003342
Train Epoch: 2 [59520/60000 (99%)]	Loss: 0.001542

Test set: Average loss: 0.0351, Accuracy: 9874/10000 (99%)
```

::: challenge

## Running multiple ways

What's another way we could have run this other than with `pixi run`?

::: solution

You can enter a shell environment first

```bash
pixi shell --environment cpu
python src/torch_MNIST.py --epochs 2 --save-model --data-dir data
```
:::
:::

#### The Linux container

Let's write a `Dockerfile` that installs the `gpu` environment into the container image when built.

::: challenge

## Write the Dockerfile

Write a `Dockerfile` that will install the `gpu` environment and only the `gpu` environment into the container image.

::: solution

```dockerfile
FROM ghcr.io/prefix-dev/pixi:noble AS build

WORKDIR /app
COPY . .
ENV CONDA_OVERRIDE_CUDA=12
RUN pixi install --locked --environment gpu
RUN echo "#!/bin/bash" > /app/entrypoint.sh && \
    pixi shell-hook --environment gpu -s bash >> /app/entrypoint.sh && \
    echo 'exec "$@"' >> /app/entrypoint.sh

FROM ghcr.io/prefix-dev/pixi:noble AS production

WORKDIR /app
COPY --from=build /app/.pixi/envs/gpu /app/.pixi/envs/gpu
COPY --from=build /app/pixi.toml /app/pixi.toml
COPY --from=build /app/pixi.lock /app/pixi.lock
# The ignore files are needed for 'pixi run' to work in the container
COPY --from=build /app/.pixi/.gitignore /app/.pixi/.gitignore
COPY --from=build /app/.pixi/.condapackageignore /app/.pixi/.condapackageignore
COPY --from=build --chmod=0755 /app/entrypoint.sh /app/entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]
```

:::
:::

#### Building and deploying the container image

Now let's add a GitHub Actions pipeline to build this Dockerfile and deploy it to a Linux container registry.

::: challenge

## Build and deploy Linux container image to registry

Add a GitHub Actions pipeline that will build the Dockerfile and deploy it to GitHub Container Registry (`ghcr`).

::: solution

Create the GitHub Actions workflow directory tree

```bash
mkdir -p .github/workflows
```

and then write a YAML file at `.github/workflows/ci.yaml` that contains the following:

```yaml
name: Build and publish Docker images

on:
  push:
    branches:
      - main
    tags:
      - 'v*'
    paths:
      - 'htcondor/pixi.toml'
      - 'htcondor/pixi.lock'
      - 'htcondor/Dockerfile'
      - 'htcondor/.dockerignore'
  pull_request:
    paths:
      - 'htcondor/pixi.toml'
      - 'htcondor/pixi.lock'
      - 'htcondor/Dockerfile'
      - 'htcondor/.dockerignore'
  release:
    types: [published]
  workflow_dispatch:

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

permissions: {}

jobs:
  docker:
    name: Build and publish images
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Docker meta
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: |
            ghcr.io/${{ github.repository }}
          # generate Docker tags based on the following events/attributes
          tags: |
            type=raw,value=hello-pytorch-noble-cuda-12.9
            type=raw,value=latest
            type=sha

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GitHub Container Registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Test build
        id: docker_build_test
        uses: docker/build-push-action@v6
        with:
          context: htcondor
          file: htcondor/Dockerfile
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          pull: true

      - name: Deploy build
        id: docker_build_deploy
        uses: docker/build-push-action@v6
        with:
          context: htcondor
          file: htcondor/Dockerfile
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          pull: true
          push: ${{ github.event_name != 'pull_request' }}
```

:::
:::

To verify that things are visible to other computers, install the Linux container utility [`crane`](https://github.com/google/go-containerregistry/tree/main/cmd/crane)

```bash
pixi global install crane
```
```console
└── crane: 0.20.5 (installed)
    └─ exposes: crane
```

and then use [`crane ls`](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane_ls.md) to list all of the container images in your container registry for the particular image

```bash
crane ls ghcr.io/<your GitHub username>/pixi-lesson
```

## HTCondor

::: callout

## This episode will be on a remote system

All the computation in the rest of this episode will take place on a remote system with an HTC workflow manager.

:::

To provide a very high level overview of HTCondor in this episode we'll focus on only a few of its many resources and capabilities.

1. Writing HTCondor execution scripts to define what the HTCondor worker nodes will actually do.
1. Writing [HTCondor submit description files](https://htcondor.readthedocs.io/en/latest/users-manual/submitting-a-job.html) to send our jobs to the HTCondor worker pool.
1. Submitting those jobs with [`condor_submit`](https://htcondor.readthedocs.io/en/latest/man-pages/condor_submit.html) and monitoring them with [`condor_q`](https://htcondor.readthedocs.io/en/latest/man-pages/condor_q.html).

::: caution

## Connection between execution scripts and submit description files

As HTCondor execution scripts are given as the `executable` field in HTCondor submit description files, they are tightly linked and can not be written fully independently.
Though they are presented as separate steps above, you will in practice write these together.

:::

### Write the HTCondor execution script

Let's first start to write the execution script `mnist_gpu_docker.sh`, as we can think about how that relates to our code.

* We'll be running in the `gpu` environment that we defined with Pixi and built into our Docker container image.
* For security reasons the HTCondor worker nodes don't have full connection to all of the internet.
So we'll need to transfer out input data and source code rather than download it on demand.
* We'll need to activate the environment using the `/app/entrypoint.sh` script we built into the Docker container image.

```bash
#!/bin/bash

# detailed logging to stderr
set -x

echo -e "# Hello CHTC from Job ${1} running on $(hostname)\n"
echo -e "# GPUs assigned: ${CUDA_VISIBLE_DEVICES}\n"

echo -e "# Activate Pixi environment\n"
# The last line of the entrypoint.sh file is 'exec "$@"'. If this shell script
# receives arguments, exec will interpret them as arguments to it, which is not
# intended. To avoid this, strip the last line of entrypoint.sh and source that
# instead.
. <(sed '$d' /app/entrypoint.sh)

echo -e "# Check to see if the NVIDIA drivers can correctly detect the GPU:\n"
nvidia-smi

echo -e "\n# Check if PyTorch can detect the GPU:\n"
python ./src/torch_detect_GPU.py

echo -e "\n# Extract the training data:\n"
if [ -f "MNIST_data.tar.gz" ]; then
    tar -vxzf MNIST_data.tar.gz
else
    echo "The training data archive, MNIST_data.tar.gz, is not found."
    echo "Please transfer it to the worker node in the HTCondor jobs submission file."
    exit 1
fi

echo -e "\n# Check that the training code exists:\n"
ls -1ap ./src/

echo -e "\n# Train MNIST with PyTorch:\n"
time python ./src/torch_MNIST.py --data-dir ./data --epochs 14 --save-model
```

### Write the HTCondor submit description file

This is pretty standard boiler plate taken from the [HTCondor documentation](https://htcondor.readthedocs.io/en/latest/users-manual/submitting-a-job.html)

```condor
# mnist_gpu_docker.sub
# Submit file to access the GPU via docker

# Set the "universe" to 'container' to use Docker
universe = container
# the container images are cached, and so if a container image tag is
# overwritten it will not be pulled again
container_image = docker://ghcr.io/<github user name>/pixi-lesson:sha-<sha>

# set the log, error and output files
log = mnist_gpu_docker.log.txt
error = mnist_gpu_docker.err.txt
output = mnist_gpu_docker.out.txt

# set the executable to run
executable = mnist_gpu_docker.sh
arguments = $(Process)

# transfer training data files to the compute node
transfer_input_files = MNIST_data.tar.gz,src

# transfer the serialized trained model back
transfer_output_files = mnist_cnn.pt

should_transfer_files = YES
when_to_transfer_output = ON_EXIT

# We require a machine with a modern version of the CUDA driver
Requirements = (Target.CUDADriverVersion >= 12.0)

# We must request 1 CPU in addition to 1 GPU
request_cpus = 1
request_gpus = 1

# select some memory and disk space
request_memory = 2GB
request_disk = 2GB

# Opt in to using CHTC GPU Lab resources
+WantGPULab = true
# Specify short job type to run more GPUs in parallel
# Can also request "medium" or "long"
+GPUJobLength = "short"

# Tell HTCondor to run 1 instances of our job:
queue 1
```

::: keypoints

* You can use containerized Pixi environments with HTC systems to be able to run CUDA accelerated code that you defined.

:::
