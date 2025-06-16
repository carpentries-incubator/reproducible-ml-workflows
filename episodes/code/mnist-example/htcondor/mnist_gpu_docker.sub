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
