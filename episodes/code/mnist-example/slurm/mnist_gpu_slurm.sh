#!/usr/bin/env bash
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
