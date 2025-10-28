---
title: "Using Pixi environments on HPC Systems"
teaching: 30
exercises: 10
---

::: questions

* How can you run workflows that use GPUs with Pixi CUDA environments using Slurm?
* What solutions exist for the resources you have?

:::

::: objectives

* Learn how to submit containerized workflows to HPC systems.

:::

## High-Performance Computing (HPC)

As mentioned in the HTC lesson, **high-performance computing (HPC)** focuses on using large computing resources, like supercomputers and high memory queues, to address large scale and compute intensive jobs that can not be weakly parallelized.
The most common HPC workflow management system is [Slurm](https://slurm.schedmd.com/).

Given the nature of HPC systems acting like "big computers", you can use Pixi with HPCs and Slurm in effectively the same manner as you would on a local machine, but just driven through Slurm.

## Setting up a problem

To demonstrate this, we'll use the same problem as we did in the HTC example.
Let's first create a new project in our Git repository

```bash
pixi init ~/pixi-cuda-lesson/slurm
cd ~/pixi-cuda-lesson/slurm
```
```output
✔ Created ~/<username>/pixi-cuda-lesson/slurm/pixi.toml
```

and use the same example code

```bash
mkdir -p src
curl -sL https://github.com/matthewfeickert/nvidia-gpu-ml-library-test/raw/c7889222544928fb6f9fdeb1145767272b5cfec8/torch_MNIST.py -o ./src/torch_MNIST.py
curl -sL https://github.com/matthewfeickert/nvidia-gpu-ml-library-test/raw/36c725360b1b1db648d6955c27bd3885b29a3273/torch_detect_GPU.py -o ./src/torch_detect_GPU.py
```

and the same Pixi workspace

```toml
[workspace]
channels = ["conda-forge"]
name = "slurm"
platforms = ["linux-64", "osx-arm64", "win-64"]
version = "0.1.0"

[tasks]

[dependencies]

[feature.cpu.dependencies]
pytorch-cpu = ">=2.7.1,<3"
torchvision = ">=0.24.0,<0.25"

[feature.gpu.system-requirements]
cuda = "12"

[feature.gpu.target.linux-64.dependencies]
pytorch-gpu = ">=2.7.1,<3"
torchvision = ">=0.24.0,<0.25"

[environments]
cpu = ["cpu"]
gpu = ["gpu"]
```

## Slurm

::: callout

## This episode will be on a remote system

All the computation in the rest of this episode will take place on a remote system with a HPC workflow manager.

:::

To provide a very high level overview of Slurm in this episode we'll focus on only a few of its many resources and capabilities.

1. Writing SLRUM execution scripts to define what the Slurm worker nodes will actually do.
1. Writing a [batch script](https://slurm.schedmd.com/sbatch.html) to send our jobs to Slurm.
1. Submitting those jobs with [`sbatch`](https://slurm.schedmd.com/sbatch.html) and monitoring them with [`squeue`](https://slurm.schedmd.com/squeue.html).

### Write the Slurm execution script

Let's first start to write the execution script `mnist_gpu.sh`, as we can think about how that relates to our code.

* We'll be running in the `gpu` environment that we defined with Pixi.
* The workers will have access to the shared files system that the login node has, so we can write our execution script as if it was local.

```bash
#!/usr/bin/env bash

# detailed logging to stderr
set -x

echo -e "# Hello from Job ${1} running on $(hostname)\n"
echo -e "# GPUs assigned: ${CUDA_VISIBLE_DEVICES}\n"

echo -e "# Check to see if the NVIDIA drivers can correctly detect the GPU:\n"
nvidia-smi

nvidia-smi --query-gpu=name,compute_cap

echo -e "\n# Check if PyTorch can detect the GPU:\n"
pixi run --environment gpu python ./src/torch_detect_GPU.py

echo -e "\n# Check that the training code exists:\n"
ls -1ap ./src/

echo -e "\n# Train MNIST with PyTorch:\n"
time pixi run --environment gpu python ./src/torch_MNIST.py --epochs 14 --data-dir ./data --save-model
```

### Write the batch script

The batch script allows us to execute our jobs with [`srun`](https://slurm.schedmd.com/srun.html) when submitted to Slurm with [`sbatch`](https://slurm.schedmd.com/sbatch.html).
Configuration options for `sbatch` can be provided through `#SBATCH` comments in the batch script header.
Note that in the `mnist_gpu_slurm.sh` there will be cluster specific information that needs to be adjusted such as:

* [`partition`](https://slurm.schedmd.com/sbatch.html#OPT_partition): Name of the partition available from [`sinfo -o "%R"`](https://slurm.schedmd.com/sinfo.html).
* [`account`](https://slurm.schedmd.com/sbatch.html#OPT_account): Match to an "Account" returned by the `accounts` command.
* [`constraint`](https://slurm.schedmd.com/sbatch.html#OPT_constraint): Constraint list on required node features, if any.

```bash
#!/usr/bin/env bash
# mnist_gpu_slurm.sh
#SBATCH --job-name="mnist_gpu"
#SBATCH --partition=<PARTITITON NAME>
#SBATCH --mem=2G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --constraint="<CONSTRAINT IF ANY>"
#SBATCH --gpus-per-node=1
#SBATCH --gpu-bind=closest  # select a cpu close to gpu on pci bus topology
#SBATCH --account=<ACCOUNT NAME>  # match to an "Account" returned by the 'accounts' command
#SBATCH --exclusive  # dedicated node for this job
#SBATCH --no-requeue
#SBATCH --time=01:00:00
#SBATCH --error mnist_gpu.slurm-%j.err
#SBATCH --output mnist_gpu.slurm-%j.out

# Ensure that no modules are loaded so starting from a clean environment
module reset

echo "job is starting on $(hostname)"

nvidia-smi

srun mnist_gpu.sh
```

### Write the submission script

To make it easy for us, we can write a small job submission script `submit.sh` that will prepare the data for us and submit the submit description file to Slurm for us with [`sbatch`](https://slurm.schedmd.com/sbatch.html).

```bash
#!/usr/bin/env bash
# submit.sh

# Ensure existing models are backed up
if [ -f "mnist_cnn.pt" ]; then
    mv mnist_cnn.pt mnist_cnn_"$(date '+%Y-%m-%d-%H-%M')".pt.bak
fi

sbatch mnist_gpu_slurm.sh
```

### Submitting the job

To submit our job, we run the `submit.sh` script

```bash
bash submit.sh
```
```output
Submitting job(s).
1 job(s) submitted to cluster 12651114.
```

and its submission and state can be monitored with [`squeue`](https://slurm.schedmd.com/squeue.html).

```bash
squeue --user $USER
```
```output


-- Schedd: ap40.uw.osg-htc.org : <128.105.68.62:9618?... @ 08/14/25 08:20:12
OWNER            BATCH_NAME      SUBMITTED   DONE   RUN    IDLE  TOTAL JOB_IDS
matthew.feickert ID: 12651114   8/14 08:18      _      1      _      1 12651114.0

1 jobs; 0 completed, 0 removed, 0 idle, 1 running, 0 held, 0 suspended

```

When the job finishes we see that Slurm has returned to us the following files:

* `mnist_gpu.slurm-$(JOBID).out`: the stdout of all actions executed in the job
* `mnist_gpu.slurm-$(JOBID).err`: the stderr of all actions executed in the job
* `mnist_cnn.pt`: the [serialized trained PyTorch model](https://docs.pytorch.org/tutorials/beginner/saving_loading_models.html#saving-loading-model-for-inference)

::: keypoints

* You can use Pixi environments with HPC systems to be able to run CUDA accelerated code that you defined.

:::
