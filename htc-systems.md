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
pixi init ~/pixi-cuda-lesson/htcondor
cd ~/pixi-cuda-lesson/htcondor
```
```output
✔ Created ~/<username>/pixi-cuda-lesson/htcondor/pixi.toml
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
mkdir -p src
curl -sL https://github.com/matthewfeickert/nvidia-gpu-ml-library-test/raw/c7889222544928fb6f9fdeb1145767272b5cfec8/torch_MNIST.py -o ./src/torch_MNIST.py
curl -sL https://github.com/matthewfeickert/nvidia-gpu-ml-library-test/raw/36c725360b1b1db648d6955c27bd3885b29a3273/torch_detect_GPU.py -o ./src/torch_detect_GPU.py
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
* Has an environment that has the GPU version of PyTorch and `torchvision` that can be installed on `linux-64`, and `win-64`.

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
pytorch-cpu = ">=2.7.1,<3"
torchvision = ">=0.22.0,<0.23"

[environments]
cpu = ["cpu"]
```

Now let's add the GPU environment and dependencies.
Let's start with the CUDA system requirements

```bash
pixi workspace system-requirements add --feature gpu cuda 12
```

and create an environment from the feature

```bash
pixi workspace environment add --feature gpu gpu
```
```output
✔ Added environment gpu
```

and then add the GPU dependencies for the target platform of `linux-64` (where we'll run in production).

```bash
pixi add --platform linux-64 --platform win-64 --feature gpu pytorch-gpu torchvision
```
```output
✔ Added pytorch-gpu >=2.7.1,<3
✔ Added torchvision >=0.22.0,<0.23
Added these only for platform(s): linux-64, win-64
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
pytorch-cpu = ">=2.7.1,<3"
torchvision = ">=0.22.0,<0.23"

[feature.gpu.system-requirements]
cuda = "12"

[feature.gpu.target.linux-64.dependencies]
pytorch-gpu = ">=2.7.1,<3"
torchvision = ">=0.22.0,<0.23"

[feature.gpu.target.win-64.dependencies]
pytorch-gpu = ">=2.7.1,<3"
torchvision = ">=0.22.0,<0.23"

[environments]
cpu = ["cpu"]
gpu = ["gpu"]
```

:::
:::


::: caution

## Override the `__cuda` virtual package

Remember that if you're on a platform that doesn't support the `system-requirement` you'll need to override the checks to **install** the environment.

```bash
export CONDA_OVERRIDE_CUDA=12
# or
# CONDA_OVERRIDE_CUDA=12 pixi <command>
```

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

##### Apptainer

Let's write an Apptainer definition file that installs the `gpu` environment, and nothing else, into the container image when built.

```
Bootstrap: docker
From: ghcr.io/prefix-dev/pixi:noble
Stage: build

# %arguments have to be defined at each stage
%arguments
    CUDA_VERSION=12
    ENVIRONMENT=gpu

%files
./pixi.toml /app/
./pixi.lock /app/
./.gitignore /app/

%post
#!/bin/bash
export CONDA_OVERRIDE_CUDA={{ CUDA_VERSION }}
cd /app/
pixi info
pixi install --locked --environment {{ ENVIRONMENT }}
echo "#!/bin/bash" > /app/entrypoint.sh && \
pixi shell-hook --environment {{ ENVIRONMENT }} -s bash >> /app/entrypoint.sh && \
echo 'exec "$@"' >> /app/entrypoint.sh


Bootstrap: docker
From: ghcr.io/prefix-dev/pixi:noble
Stage: final

%arguments
    ENVIRONMENT=gpu

%files from build
/app/.pixi/envs/{{ ENVIRONMENT }} /app/.pixi/envs/{{ ENVIRONMENT }}
/app/pixi.toml /app/pixi.toml
/app/pixi.lock /app/pixi.lock
/app/.gitignore /app/.gitignore
# The ignore files are needed for 'pixi run' to work in the container
/app/.pixi/.gitignore /app/.pixi/.gitignore
/app/.pixi/.condapackageignore /app/.pixi/.condapackageignore
/app/entrypoint.sh /app/entrypoint.sh

%post
#!/bin/bash
cd /app/
pixi info
chmod +x /app/entrypoint.sh

%runscript
#!/bin/bash
/app/entrypoint.sh "$@"

%startscript
#!/bin/bash
/app/entrypoint.sh "$@"

%test
#!/bin/bash -e
. /app/entrypoint.sh
pixi info
pixi list
```

##### Docker

Let's write a `Dockerfile` that installs the `gpu` environment into the container image when built.

::: challenge

## Write the Dockerfile

Write a `Dockerfile` that will install the `gpu` environment and only the `gpu` environment into the container image.

::: solution

```dockerfile
ARG CUDA_VERSION="12"
ARG ENVIRONMENT="gpu"

FROM ghcr.io/prefix-dev/pixi:noble AS build

ARG CUDA_VERSION
ARG ENVIRONMENT

WORKDIR /app
COPY . .
ENV CONDA_OVERRIDE_CUDA=$CUDA_VERSION
RUN pixi install --locked --environment $ENVIRONMENT
RUN echo "#!/bin/bash" > /app/entrypoint.sh && \
    pixi shell-hook --environment $ENVIRONMENT -s bash >> /app/entrypoint.sh && \
    echo 'exec "$@"' >> /app/entrypoint.sh

FROM ghcr.io/prefix-dev/pixi:noble AS final

ARG ENVIRONMENT

WORKDIR /app
COPY --from=build /app/.pixi/envs/$ENVIRONMENT /app/.pixi/envs/$ENVIRONMENT
COPY --from=build /app/pixi.toml /app/pixi.toml
COPY --from=build /app/pixi.lock /app/pixi.lock
COPY --from=build /app/.pixi/.gitignore /app/.pixi/.gitignore
COPY --from=build /app/.pixi/.condapackageignore /app/.pixi/.condapackageignore
COPY --from=build --chmod=0755 /app/entrypoint.sh /app/entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]
```

:::
:::

#### Building and deploying the container image

Now let's add a GitHub Actions pipeline to build the container image definition files (apptainer.def and Dockerfile) and deploy it to a Linux container registry.

::: challenge

## Build and deploy Linux container image to registry

Add a GitHub Actions pipeline that will build both the apptainer.def and Dockerfile files deploy them to GitHub Container Registry (`ghcr`).
Have the image tags include the text `mnist` as this will be the identifying problem.

::: solution

Create the GitHub Actions workflow directory tree

```bash
mkdir -p .github/workflows
```

and then write a YAML file at `.github/workflows/containers.yaml` that contains the following:

```yaml
name: Build and publish Linux container images

on:
  push:
    branches:
      - main
    tags:
      - 'v*'
    paths:
      - 'htcondor/pixi.toml'
      - 'htcondor/pixi.lock'
      - 'htcondor/apptainer.def'
      - 'htcondor/Dockerfile'
      - 'htcondor/.dockerignore'
  pull_request:
    paths:
      - 'htcondor/pixi.toml'
      - 'htcondor/pixi.lock'
      - 'htcondor/apptainer.def'
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
    name: Build and publish Docker images
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
            type=raw,value=mnist-gpu-noble-cuda-12.9
            type=raw,value=latest
            type=sha
            type=sha,prefix=mnist-gpu-noble-cuda-12.9-sha-

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

  apptainer:
    name: Build and publish Apptainer images
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Free disk space
        uses: AdityaGarg8/remove-unwanted-software@v5
        with:
          remove-android: 'true'
          remove-dotnet: 'true'
          remove-haskell: 'true'

      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Get commit SHA
        id: meta
        run: |
            # Get the short commit SHA (first 7 characters)
            SHA=$(git rev-parse --short HEAD)
            echo "sha=sha-$SHA" >> $GITHUB_OUTPUT

      - name: Install Apptainer
        uses: eWaterCycle/setup-apptainer@v2

      - name: Build container from definition file
        working-directory: ./htcondor
        run: apptainer build gpu-noble-cuda-12.9.sif apptainer.def

      - name: Test container
        working-directory: ./htcondor
        run: apptainer test gpu-noble-cuda-12.9.sif

      - name: Login to GitHub Container Registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Deploy built container
        if: github.event_name != 'pull_request'
        working-directory: ./htcondor
        run: apptainer push gpu-noble-cuda-12.9.sif oras://ghcr.io/${{ github.repository }}:apptainer-mnist-gpu-noble-cuda-12.9-${{ steps.meta.outputs.sha }}
```

:::
:::

::: callout

## Version Control

We now want to make sure that we can build container images with these defention files and workflows.

On a **new branch** in your repository, add and commit the files from this episode.

```bash
git add htcondor/pixi.*
git add htcondor/.git*
git add htcondor/apptainer.def
git add htcondor/Dockerfile.def
git add .github/workflows/containers.yaml
```

Then push your branch to your remote on GitHub

```bash
git push -u origin HEAD
```

and make a pull request to merge your changes into your remote's default branch.

:::

To verify that things are visible to other computers, install the Linux container utility [`crane`](https://github.com/google/go-containerregistry/tree/main/cmd/crane)

```bash
pixi global install crane
```
```console
└── crane: 0.20.5 (installed)
    └─ exposes: crane
```

and then use [`crane ls`](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane_ls.md) to list all of the Docker container images in your container registry for the particular image

```bash
crane ls ghcr.io/<your GitHub username>/pixi-cuda-lesson
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

Let's first start to write the execution script `mnist_gpu_apptainer.sh`, as we can think about how that relates to our code.

* We'll be running in the `gpu` environment that we defined with Pixi and built into our Apptainer container image.
* For security reasons the HTCondor worker nodes don't have full connection to all of the internet.
So we'll need to transfer out input data and source code rather than download it on demand.
* We'll need to activate the environment using the `/app/entrypoint.sh` script we built into the Apptainer container image.

```bash
#!/bin/bash

# detailed logging to stderr
set -x

echo -e "# Hello from Job ${1} running on $(hostname)\n"
echo -e "# GPUs assigned: ${CUDA_VISIBLE_DEVICES}\n"

echo -e "# Activate Pixi environment\n"
# The last line of the entrypoint.sh file is 'exec "$@"'. If this shell script
# receives arguments, exec will interpret them as arguments to it, which is not
# intended. To avoid this, strip the last line of entrypoint.sh and source that
# instead.
. <(sed '$d' /app/entrypoint.sh)

# Note: Use of nvidia-smi in Apptainer requires the '--nvccli' option.
# https://apptainer.org/docs/user/main/gpu.html#nvidia-gpus-cuda-nvidia-container-cli
# As of 2025-06-12, CHTC supports '--nv' but not '--nvccli' and so 'nvidia-smi'
# can not be used.
#
# echo -e "# Check to see if the NVIDIA drivers can correctly detect the GPU:\n"
# nvidia-smi

echo -e "\n# Check that the training code exists:\n"
ls -1ap ./src/

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

echo -e "\n# Train MNIST with PyTorch:\n"
time python ./src/torch_MNIST.py --data-dir ./data --epochs 14 --save-model
```

### Write the HTCondor submit description file

This is pretty standard boiler plate taken from the [HTCondor documentation](https://htcondor.readthedocs.io/en/latest/users-manual/submitting-a-job.html)

```condor
# mnist_gpu_apptainer.sub
# Submit file to access the GPU via apptainer

universe = container
container_image = oras://ghcr.io/<github user name>/pixi-cuda-lesson:apptainer-mnist-gpu-noble-cuda-12.9-sha-<sha>

# set the log, error and output files
log = mnist_gpu_apptainer_$(Cluster)_$(Process).log.txt
error = mnist_gpu_apptainer_$(Cluster)_$(Process).err.txt
output = mnist_gpu_apptainer_$(Cluster)_$(Process).out.txt

# set the executable to run
executable = mnist_gpu_apptainer.sh
arguments = $(Process)

+JobDurationCategory = "Medium"

# transfer training data files and runtime source files to the compute node
transfer_input_files = MNIST_data.tar.gz,src

# transfer the serialized trained model back
transfer_output_files = mnist_cnn.pt

should_transfer_files = YES
when_to_transfer_output = ON_EXIT

# Require a machine with a modern version of the CUDA driver
requirements = (GPUs_DriverVersion >= 12.0)

# Don't use CentOS7 to ensure pty support
requirements = (OpSysMajorVer > 7)

# We must request 1 CPU in addition to 1 GPU
request_cpus = 1
request_gpus = 1

# select some memory and disk space
request_memory = 2GB
# Apptainer jobs take more disk than Docker jobs for some reason
request_disk = 7GB

# Optional: specify the GPU hardware architecture required
# Check against the CUDA GPU Compute Capability for your software
# e.g. python -c "import torch; print(torch.cuda.get_arch_list())"
# The listed 'sm_xy' values show the x.y gpu capability supported
gpus_minimum_capability = 5.0

# Optional: required GPU memory
# gpus_minimum_memory = 4GB

# Tell HTCondor to run 1 instances of our job:
queue 1
```

### Write the submission script

To make it easy for us, we can write a small job submission script `submit.sh` that will prepare the data for us and submit the submit description file to HTCondor for us with [`condor_submit`](https://htcondor.readthedocs.io/en/latest/man-pages/condor_submit.html).

```bash
#!/bin/bash

# Download the training data locally to transfer to the worker node
if [ ! -f "MNIST_data.tar.gz" ]; then
    # c.f. https://github.com/CHTC/templates-GPUs/blob/450081144c6ae0657123be2a9a357cb432d9d394/shared/pytorch/MNIST_data.tar.gz
    curl -sLO https://raw.githubusercontent.com/CHTC/templates-GPUs/450081144c6ae0657123be2a9a357cb432d9d394/shared/pytorch/MNIST_data.tar.gz
fi

# Ensure existing models are backed up
if [ -f "mnist_cnn.pt" ]; then
    mv mnist_cnn.pt mnist_cnn_"$(date '+%Y-%m-%d-%H-%M')".pt.bak
fi

condor_submit mnist_gpu_apptainer.sub
```

### Submitting the job

Before we actually submit code to run, we can submit an interactive job from the HTCondor system's login nodes to check that things work as expected.

```bash
#!/bin/bash

# Download the training data locally to transfer to the worker node
if [ ! -f "MNIST_data.tar.gz" ]; then
    # c.f. https://github.com/CHTC/templates-GPUs/blob/450081144c6ae0657123be2a9a357cb432d9d394/shared/pytorch/MNIST_data.tar.gz
    curl -sLO https://raw.githubusercontent.com/CHTC/templates-GPUs/450081144c6ae0657123be2a9a357cb432d9d394/shared/pytorch/MNIST_data.tar.gz
fi

# Ensure existing models are backed up
if [ -f "mnist_cnn.pt" ]; then
    mv mnist_cnn.pt mnist_cnn_"$(date '+%Y-%m-%d-%H-%M')".pt.bak
fi

condor_submit -interactive mnist_gpu_apptainer.sub
```

Submitting the job for the first time will take a bit as it needs to pull down the container image, so be patient.
The container image will be cached in the future and so this will be faster.

```bash
bash interact.sh
```
```output
Submitting job(s).
1 job(s) submitted to cluster 2127828.
Waiting for job to start...
...
Welcome to interactive3_1@vetsigian0001.chtc.wisc.edu!
Your condor job is running with pid(s) 2368233.
groups: cannot find name for group ID 24433
groups: cannot find name for group ID 40092
I have no name!@vetsigian0001:/var/lib/condor/execute/slot3/dir_2367762$
```

We can now activate our environment manually and look around

```bash
. /app/entrypoint.sh
```
```output
(htcondor:gpu) I have no name!@vetsigian0001:/var/lib/condor/execute/slot3/dir_2367762$
```

```bash
command -v python
```
```output
/app/.pixi/envs/gpu/bin/python
```

```bash
python --version
```
```output
Python 3.13.5
```

```bash
pixi list pytorch
```
```output
Environment: gpu
Package      Version  Build                           Size      Kind   Source
pytorch      2.7.0    cuda126_mkl_py313_he20fe19_300  27.8 MiB  conda  https://conda.anaconda.org/conda-forge/
pytorch-gpu  2.7.0    cuda126_mkl_ha999a5f_300        46.1 KiB  conda  https://conda.anaconda.org/conda-forge/
```

```bash
pixi list cuda
```
```output
Environment: gpu
Package               Version  Build       Size       Kind   Source
cuda-crt-tools        12.9.86  ha770c72_1  28.2 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-cudart           12.9.79  h5888daf_0  22.7 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-cudart_linux-64  12.9.79  h3f2d84a_0  192.6 KiB  conda  https://conda.anaconda.org/conda-forge/
cuda-cuobjdump        12.9.82  hbd13f7d_0  237.5 KiB  conda  https://conda.anaconda.org/conda-forge/
cuda-cupti            12.9.79  h9ab20c4_0  1.8 MiB    conda  https://conda.anaconda.org/conda-forge/
cuda-nvcc-tools       12.9.86  he02047a_1  26.2 MiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvdisasm         12.9.88  hbd13f7d_0  5.3 MiB    conda  https://conda.anaconda.org/conda-forge/
cuda-nvrtc            12.9.86  h5888daf_0  64.1 MiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvtx             12.9.79  h5888daf_0  28.6 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvvm-tools       12.9.86  he02047a_1  23.1 MiB   conda  https://conda.anaconda.org/conda-forge/
cuda-version          12.9     h4f385c5_3  21.1 KiB   conda  https://conda.anaconda.org/conda-forge/
```

```bash
nvidia-smi
```
```output
Mon Jun 16 00:07:33 2025
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.54.14              Driver Version: 550.54.14      CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 2080 Ti     On  |   00000000:B2:00.0 Off |                  N/A |
| 29%   26C    P8             23W /  250W |       3MiB /  11264MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

We can interactively run our code as well

```bash
tar -vxzf MNIST_data.tar.gz
time python ./src/torch_MNIST.py --data-dir ./data --epochs 2 --save-model
```

To return to the login node we just `exit` the interactive session

```bash
exit
```

Now to submit our job normally, we run the `submit.sh` script

```bash
bash submit.sh
```
```output
Submitting job(s).
1 job(s) submitted to cluster 2127879.
```

and its submission and state can be monitored with [`condor_q`](https://htcondor.readthedocs.io/en/latest/man-pages/condor_q.html).

```bash
condor_q
```
```output


-- Schedd: ap2001.chtc.wisc.edu : <128.105.68.112:9618?... @ 06/15/25 19:16:17
OWNER     BATCH_NAME     SUBMITTED   DONE   RUN    IDLE  TOTAL JOB_IDS
mfeickert ID: 2127879   6/15 19:13      _      1      _      1 2127879.0

1 jobs; 0 completed, 0 removed, 0 idle, 1 running, 0 held, 0 suspended

```

When the job finishes we see that HTCondor has returned to us the following files:

* `mnist_gpu_docker.log.txt`: the HTCondor log file for the job
* `mnist_gpu_docker.out.txt`: the stdout of all actions executed in the job
* `mnist_gpu_docker.err.txt`: the stderr of all actions executed in the job
* `mnist_cnn.pt`: the [serialized trained PyTorch model](https://docs.pytorch.org/tutorials/beginner/saving_loading_models.html#saving-loading-model-for-inference)

::: keypoints

* You can use containerized Pixi environments with HTC systems to be able to run CUDA accelerated code that you defined.

:::
