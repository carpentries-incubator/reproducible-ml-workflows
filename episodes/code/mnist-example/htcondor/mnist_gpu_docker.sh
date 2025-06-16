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
