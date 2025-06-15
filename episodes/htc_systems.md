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

Now let's think about what we'd like to do with this code.

::: keypoints

* You can use containerized Pixi environments with HTC systems to be able to run CUDA accelerated code that you defined.

:::
