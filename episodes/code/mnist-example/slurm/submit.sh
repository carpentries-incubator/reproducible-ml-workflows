#!/usr/bin/env bash

# Ensure existing models are backed up
if [ -f "mnist_cnn.pt" ]; then
    mv mnist_cnn.pt mnist_cnn_"$(date '+%Y-%m-%d-%H-%M')".pt.bak
fi

sbatch hello_pytorch_gpu_slurm.sh
