---
title: "Using Pixi environments on HTC Systems"
teaching: 40
exercises: 10
---

::: questions

* How can you run workflows that use GPUs with Pixi CUDA environments?
* What solutions exist for the resources you have?

:::

::: objectives

* Learn how to submit containerized workflows to HTC systems.

:::

::: callout

## This episode will be on a remote system

All the computation in this episode will take place on a remote system with an HTC workflow manager.

:::

## High Throughput Computing (HTC)

One of the most common forms of production computing is **high-throughput computing (HTC)**, where computational problems as distributed across multiple computing resources to parallelize computations and reduce total compute time.
HTC resources are quite dynamic, but usually focus on smaller memory and disk requirements on each individual worker compute node.
This is in contrast to **high-performance computing (HPC)** where there are comparatively fewer compute nodes but the capabilities and associated memory, disk, and bandwidth resources are much higher.

Two of the most common HTC workflow management systems are [HTCondor](https://htcondor.org/) and [SLURM](https://slurm.schedmd.com/).

## HTCondor

To provide a very high level overview of HTCondor in this episode we'll focus on only a few of its many resources and capabilities.

1. Writing HTCondor execution scripts to define what the HTCondor worker nodes will actually do.
1. Writing [HTCondor submit description files](https://htcondor.readthedocs.io/en/latest/users-manual/submitting-a-job.html) to send our jobs to the HTCondor worker pool.
1. Submitting those jobs with [`condor_submit`](https://htcondor.readthedocs.io/en/latest/man-pages/condor_submit.html) and monitoring them with [`condor_q`](https://htcondor.readthedocs.io/en/latest/man-pages/condor_q.html).

::: caution

## Connection between execution scripts and submit description files

As HTCondor execution scripts are given as the `executable` field in HTCondor submit description files, they are tightly linked and can not be written fully independently.
Though they are presented as separate steps above, you will in practice write these together.

:::

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

To validate that things are working with the CPU code, let's do a short training run for only 4 epochs in the `cpu` environment.

::: keypoints

* You can use containerized Pixi environments with HTC systems to be able to run CUDA accelerated code that you defined.

:::
