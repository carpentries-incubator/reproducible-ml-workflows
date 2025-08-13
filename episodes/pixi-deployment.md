---
title: "Deploying Pixi environments with Linux containers"
teaching: 30
exercises: 15
---

::: questions

* How can Pixi environment be deployed to production compute facilities?
* What tools can be used to achieve this?

:::

::: objectives

* Version control Pixi environments with Git.
* Create a Linux container that has a production environment.
* Create an automated GitHub Actions workflow to build and deploy environments.

:::

## Deploying Pixi environments

We now know how to create Pixi workspaces that contain environments that can support CUDA enabled code.
However, unless your production machine learning environment is a lab desktop with GPUs and lots of disk ^[Which is a valid and effective solution.] that you can install Pixi on and run your code then we still need to be able to get our Pixi environments to our production machines.

There is one very straightforward solution:

1. Version control your Pixi manifest and Pixi lock files with your analysis code with a version control system (e.g. Git).
1. Clone your repository to the machine that you want to run on.
1. Install Pixi onto that machine.
1. Install the locked Pixi environment that you want to use.
1. Execute your code in the installed environment.

That's a nice and simple story, and it can work!
However, in most realistic scenarios the worker compute nodes that are executing code share resource pools of storage and memory and are regulated to smaller allotments of both.
CUDA binaries are relatively large files and amount of memory and storage to just unpack them can easily exceed a standard 2 GB memory limit on most high throughput computing (HTC) facility worker nodes.
This also requires direct access to the public internet, or for you to setup a [S3 object store](https://pixi.sh/latest/deployment/s3/) behind your compute facility's firewall with all of your conda packages mirrored into it.
In many scenarios, public internet access at HTC and high performance computing (HPC) facilities is limited to only a select "allow list" of websites or it might be fully restricted for users.

## Building Linux containers with Pixi environments

A more standard and robust way of distributing computing environments is the use of [Linux container](https://pixi.sh/latest/deployment/container/) technology &mdash; like Docker or Apptainer.

::: callout

## Conceptualizing the role of Linux containers

Linux containers are powerful technologies that allow for arbitrary software environments to be distributed as a single binary.
However, it is important to **not** think of Linux containers as _packaging_ technologies (like conda packages) but as _distribution_ technologies.
When you build a Linux container you provide a set of imperative commands as a build script that constructs different layers of the container.
When the build is finished, all layers of the build are compressed together to form a container image binary that can be distributed through Linux container image registries.

Packaging technologies allow for defining requirements and constraints on a unit of software that we call a "package".
Packages can be installed together and their metadata allows them to be composed programmatically into software environments.

Linux containers take defined software environments and instantiate them by installing them into the container image during the build and then distribute that entire computing environment for a **single platform**.

:::

::: callout

## Resources on Linux containers

Linux containers are a full topic unto themselves and we won't cover them in this lesson.
If you're not familiar with Linux containers, here are introductory resources:

* [Reproducible Computational Environments Using Containers: Introduction to Docker](https://carpentries-incubator.github.io/docker-introduction/), a [The Carpentries Incubator](https://github.com/carpentries-incubator/proposals/#the-carpentries-incubator) lesson
* [Introduction to Docker and Podman](https://hsf-training.github.io/hsf-training-docker/index.html) by the [High Energy Physics Software Foundation](https://hepsoftwarefoundation.org/)
* [Reproducible computational environments using containers: Introduction to Apptainer](https://carpentries-incubator.github.io/apptainer-introduction/), a [The Carpentries Incubator](https://github.com/carpentries-incubator/proposals/#the-carpentries-incubator) lesson

:::

If you don't have a Linux container runtime on your machine don't worry &mdash; for the first part of this episode you can follow along reading and then we'll transition to automation.

## Building Docker containers with Pixi environments

Docker is a very common Linux container runtime technology and Linux container builder.
We can use [`docker build`](https://docs.docker.com/build/) to build a Linux container from a `Dockerfile` instruction file.
Luckily, to install Pixi environments into Docker container images there is **effectively only one `Dockerfile` recipe** that needs to be used, and then can be reused across projects.

::: callout

## Moving files

To use it later, we'll place the `torch_detect_GPU.py` code from the end of the CUDA conda packages episode at `./app/torch_detect_GPU.py`.

```bash
mkdir -p app
curl -sL https://github.com/matthewfeickert/nvidia-gpu-ml-library-test/raw/36c725360b1b1db648d6955c27bd3885b29a3273/torch_detect_GPU.py -o ./app/torch_detect_GPU.py
```

:::

```dockerfile
# Declare build ARGs in global scope
ARG CUDA_VERSION="12"
ARG ENVIRONMENT="gpu"

FROM ghcr.io/prefix-dev/pixi:noble AS build

# Redeclaring ARGs in a stage without a value inherits the global default
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
# The ignore files are needed for 'pixi run' to work in the container
COPY --from=build /app/.pixi/.gitignore /app/.pixi/.gitignore
COPY --from=build /app/.pixi/.condapackageignore /app/.pixi/.condapackageignore
COPY --from=build --chmod=0755 /app/entrypoint.sh /app/entrypoint.sh

# This bit is needed only if you have code you _want_ to deploy in the container.
# This is rare as you normally want your code to be able to get brought into a container later.
COPY ./app /app/src

ENTRYPOINT [ "/app/entrypoint.sh" ]
```

::: spoiler

## Dockerfile walkthrough

Let's step through this to understand what's happening.
`Dockerfile`s (intentionally) look very shell script like, and so we can read most of it as if we were typing the commands directly into a shell (e.g. Bash).

* The `Dockerfile` assumes it is being built from a version control repository where any code that it will need to execute later exists under the repository's `src/` directory and the Pixi workspace's `pixi.toml` manifest file and `pixi.lock` lock file exist at the top level of the repository.

* Dockerfile [`ARG`](https://docs.docker.com/reference/dockerfile/#arg)s are declared _before_ the `build` stage's base image `FROM` declaration, meaning they have [global scope](https://docs.docker.com/build/building/variables/#scoping).
Declaring the `ARG`s again with no value in the local scope of the `build` stage inherits the global scope values.

```dockerfile
# Declare build ARGS in global scope
ARG CUDA_VERSION="12"
ARG ENVIRONMENT="gpu"

FROM ghcr.io/prefix-dev/pixi:noble AS build

# Redeclaring ARGs in a stage without a value inherits the global default
ARG CUDA_VERSION
ARG ENVIRONMENT
```

* The entire repository contents are [`COPY`](https://docs.docker.com/reference/dockerfile/#copy)ed from the container build context into the `/app` directory of the container build.

```dockerfile
WORKDIR /app
COPY . .
```

* It is not reasonable to expect that the container image build machine contains GPUs.
To have Pixi still be able to install an environment that uses CUDA when there is no virtual package set the `__cuda` [override environment variable `CONDA_OVERRIDE_CUDA`](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-virtual.html#overriding-detected-packages).

```dockerfile
ENV CONDA_OVERRIDE_CUDA=$CUDA_VERSION
```

* The `Dockerfile` uses a [multi-stage](https://docs.docker.com/build/building/multi-stage/) build where it first installs the target environment `$ENVIRONMENT` and then creates an [`ENTRYPOINT`](https://docs.docker.com/reference/dockerfile/#entrypoint) script using [`pixi shell-hook`](https://pixi.sh/latest/reference/cli/pixi/shell-hook/) to automatically activate the environment when the container image is run.

```dockerfile
RUN pixi install --locked --environment $ENVIRONMENT
RUN echo "#!/bin/bash" > /app/entrypoint.sh && \
    pixi shell-hook --environment $ENVIRONMENT -s bash >> /app/entrypoint.sh && \
    echo 'exec "$@"' >> /app/entrypoint.sh
```

* The next stage of the build starts from a new container instance and then [`COPY`](https://docs.docker.com/reference/dockerfile/#copy)s the installed environment and files **from** the build container image into the production container image.
This can reduce the total size of the final container image if there were additional build tools that needed to get installed in the build phase that aren't required for runtime in production.

```dockerfile
FROM ghcr.io/prefix-dev/pixi:noble AS final

ARG ENVIRONMENT

WORKDIR /app
COPY --from=build /app/.pixi/envs/$ENVIRONMENT /app/.pixi/envs/$ENVIRONMENT
COPY --from=build /app/pixi.toml /app/pixi.toml
COPY --from=build /app/pixi.lock /app/pixi.lock
# The ignore files are needed for 'pixi run' to work in the container
COPY --from=build /app/.pixi/.gitignore /app/.pixi/.gitignore
COPY --from=build /app/.pixi/.condapackageignore /app/.pixi/.condapackageignore
COPY --from=build --chmod=0755 /app/entrypoint.sh /app/entrypoint.sh
```

* Code that is specific to application purposes (e.g. environment diagnostics) from the repository is [`COPY`](https://docs.docker.com/reference/dockerfile/#copy)ed into the final container image as well

```dockerfile
COPY ./app /app/src
```

::: caution

## Knowing what code to copy

Generally you do **not** want to containerize your development source code, as you'd like to be able to quickly iterate on it and have it be transferred into a Linux container to be evaluated.

You **do** want to containerize your development source code if you'd like to archive it as an executable into the future.

:::

* The [`ENTRYPOINT`](https://docs.docker.com/reference/dockerfile/#entrypoint) script is set for activation


```dockerfile
ENTRYPOINT [ "/app/entrypoint.sh" ]
```

:::

With this `Dockerfile` the container image can then be built with [`docker build`](https://docs.docker.com/reference/cli/docker/buildx/build/).

### Automation with GitHub Actions workflows

In the personal GitHub repository that we've been working in, create a GitHub Actions workflow directory from the top level of the repository

```bash
mkdir -p .github/workflows
```

and then add the following workflow file as `.github/workflows/docker.yaml`

```yaml
name: Docker Images

on:
  push:
    branches:
      - main
    tags:
      - 'v*'
    paths:
      - 'cuda-exercise/pixi.toml'
      - 'cuda-exercise/pixi.lock'
      - 'cuda-exercise/Dockerfile'
      - 'cuda-exercise/.dockerignore'
      - 'cuda-exercise/app/**'
  pull_request:
    paths:
      - 'cuda-exercise/pixi.toml'
      - 'cuda-exercise/pixi.lock'
      - 'cuda-exercise/Dockerfile'
      - 'cuda-exercise/.dockerignore'
      - 'cuda-exercise/app/**'
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
            type=raw,value=noble-cuda-12.9
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
          context: cuda-exercise
          file: cuda-exercise/Dockerfile
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          pull: true

      - name: Deploy build
        id: docker_build_deploy
        uses: docker/build-push-action@v6
        with:
          context: cuda-exercise
          file: cuda-exercise/Dockerfile
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          pull: true
          push: ${{ github.event_name != 'pull_request' }}
```

This will build your Dockerfile in GitHub Actions CI into a [`linux/amd64` platform](https://docs.docker.com/build/building/multi-platform/) Docker container image and then deploy it to the [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) (`ghcr`) associated with your repository.

## Building Apptainer containers with Pixi environments

Most HTC and HPC systems do not allow users to use Docker given security risks and instead use Apptainer.
In most situations, Apptainer is able to automatically convert a Docker image, or other Open Container Initiative (OCI) container image format, to Apptainer's [Singularity Image Format](https://github.com/apptainer/sif) `.sif` container image format, and so no additional work is required.
However, the overlay system of Apptainer is different from Docker, which means that the `ENTRYPOINT` of a Docker container image might not get correctly translated into an Apptainer `runscript` and `startscript`.
In might be advantageous, depending on your situation, to instead write an [Apptainer `.def` definition file](https://apptainer.org/docs/user/main/definition_files.html), giving full control over the commands, and then build that `.def` file into an `.sif` Apptainer container image.

We can build a very similar Apptainer container image definition file to the Dockerfile we wrote

```
Bootstrap: docker
From: ghcr.io/prefix-dev/pixi:noble
Stage: build

%files
./pixi.toml /app/
./pixi.lock /app/
./.gitignore /app/

%post
#!/bin/bash
export CONDA_OVERRIDE_CUDA=12
cd /app/
pixi info
pixi install --locked --environment prod
echo "#!/bin/bash" > /app/entrypoint.sh && \
pixi shell-hook --environment prod -s bash >> /app/entrypoint.sh && \
echo 'exec "$@"' >> /app/entrypoint.sh


Bootstrap: docker
From: ghcr.io/prefix-dev/pixi:noble
Stage: final

%files from build
/app/.pixi/envs/prod /app/.pixi/envs/prod
/app/pixi.toml /app/pixi.toml
/app/pixi.lock /app/pixi.lock
/app/.gitignore /app/.gitignore
# The ignore files are needed for 'pixi run' to work in the container
/app/.pixi/.gitignore /app/.pixi/.gitignore
/app/.pixi/.condapackageignore /app/.pixi/.condapackageignore
/app/entrypoint.sh /app/entrypoint.sh

%files
./app /app/src

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

Let's break this down too.

::: spoiler

## Apptainer walkthrough

* The Apptainer definition file is broken out into specific [operation sections](https://apptainer.org/docs/user/main/definition_files.html#sections) prefixed by `%` (e.g. `files`, `post`).
* The Apptainer definition file assumes it is being built from a version control repository where any code that it will need to execute later exists under the repository's `src/` directory and the Pixi workspace's `pixi.toml` manifest file and `pixi.lock` lock file exist at the top level of the repository.
* The [`files` section](https://apptainer.org/docs/user/main/definition_files.html#files) allows for a mapping of what files should be copied from a build context (e.g. the local file system) to the container file system

```singularity
%files
./pixi.toml /app/
./pixi.lock /app/
./.gitignore /app/
````

* The [`post` section](https://apptainer.org/docs/user/main/definition_files.html#post) runs commands listed in it as a shell script executed in a clean shell environment that does not have any pre-existing build environment context.
It is not reasonable to expect that the container image build machine contains GPUs.
To have Pixi still be able to install an environment that uses CUDA when there is no virtual package set the `__cuda` [override environment variable `CONDA_OVERRIDE_CUDA`](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-virtual.html#overriding-detected-packages).

```
%post
#!/bin/bash
export CONDA_OVERRIDE_CUDA=12
...
```

* The definition files uses a [multi-stage build](https://apptainer.org/docs/user/main/definition_files.html#multi-stage-builds) where it first installs the target environment `<environment>` and then creates an `entrypoint.sh` script script that will be used as a [`runscript`](https://apptainer.org/docs/user/main/definition_files.html#runscript) using [`pixi shell-hook`](https://pixi.sh/latest/reference/cli/pixi/shell-hook/) to automatically activate the environment when the container image is run.

```
...
cd /app/
pixi info
pixi install --locked --environment prod
echo "#!/bin/bash" > /app/entrypoint.sh && \
pixi shell-hook --environment prod -s bash >> /app/entrypoint.sh && \
echo 'exec "$@"' >> /app/entrypoint.sh
```

* The next stage of the build starts from a new container instance and then copies the installed environment and files **from** the `build` stage into the `final` container image.
This can reduce the total size of the final container image if there were additional build tools that needed to get installed in the build phase that aren't required for runtime in production.

```
Bootstrap: docker
From: ghcr.io/prefix-dev/pixi:noble
Stage: final

%files from build
/app/.pixi/envs/prod /app/.pixi/envs/prod
/app/pixi.toml /app/pixi.toml
/app/pixi.lock /app/pixi.lock
/app/.gitignore /app/.gitignore
# The ignore files are needed for 'pixi run' to work in the container
/app/.pixi/.gitignore /app/.pixi/.gitignore
/app/.pixi/.condapackageignore /app/.pixi/.condapackageignore
/app/entrypoint.sh /app/entrypoint.sh
```

* By repeating the `files` section we can also copy in the source code

```
%files
./app /app/src
```

* The `post` section then verifies that the Pixi workspace is valid and makes the `/app/entrypoint.sh` executable

```
%post
#!/bin/bash
cd /app/
pixi info
chmod +x /app/entrypoint.sh
```

* The [`runscript` section](https://apptainer.org/docs/user/main/definition_files.html#runscript) defines a shell script that will get executed when the container image is run (either via the [`apptainer run`](https://apptainer.org/docs/user/main/cli/apptainer_run.html) command or by [executing the container directly as a command](https://apptainer.org/docs/user/main/quick_start.html#runcontainer)).

```
%runscript
#!/bin/bash
/app/entrypoint.sh "$@"
```

* We also define a [`startscript` section](https://apptainer.org/docs/user/main/definition_files.html#startscript) that is the same as the `runscript`'s contents that is executed when the [`instance start`](https://apptainer.org/docs/user/main/cli/apptainer_instance_start.html) command is executed (which creates a container instances that starts running in the background).

```
%startscript
#!/bin/bash
/app/entrypoint.sh "$@"
```

* Finally, the [`test` section](https://apptainer.org/docs/user/main/definition_files.html#test) defines a script that will be executed in the built container at the end of the build process.
This allows for validation of the container functionality before it is distributed.

```
%test
#!/bin/bash -e
. /app/entrypoint.sh
pixi info
pixi list
```

:::

With this Apptainer defintion file the container image can then be built with `apptainer build`

```bash
apptainer build <container image name>.sif <definition file name>.def
```

### Automation with GitHub Actions workflows

In the personal GitHub repository that we've been working in create a GitHub Actions workflow directory

```bash
mkdir -p .github/workflows
```

and then add the following workflow file as `.github/workflows/apptainer.yaml`

```yaml
name: Apptainer Images

on:
  push:
    branches:
      - main
    tags:
      - 'v*'
    paths:
      - 'cuda-exercise/pixi.toml'
      - 'cuda-exercise/pixi.lock'
      - 'cuda-exercise/apptainer.def'
      - 'cuda-exercise/app/**'
  pull_request:
    paths:
      - 'cuda-exercise/pixi.toml'
      - 'cuda-exercise/pixi.lock'
      - 'cuda-exercise/apptainer.def'
      - 'cuda-exercise/app/**'
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

      - name: Install Apptainer
        uses: eWaterCycle/setup-apptainer@v2

      - name: Build container from definition file
        working-directory: ./examples/hello_pytorch
        run: apptainer build pixi-docker-chtc.sif apptainer.def

      - name: Test container
        working-directory: ./examples/hello_pytorch
        run: apptainer test pixi-docker-chtc.sif

      - name: Login to GitHub Container Registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Deploy built container
        if: github.event_name != 'pull_request'
        working-directory: ./examples/hello_pytorch
        run: apptainer push pixi-docker-chtc.sif oras://ghcr.io/${{ github.repository }}:hello-pytorch-noble-cuda-12.9-apptainer
```

This will build your Apptainer definition file in GitHub Actions CI into a `.sif` container image and then deploy it to the [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) (`ghcr`) associated with your repository.

::: keypoints

* Pixi environments can be easily installed into Linux containers.
* As Pixi environments contain the entire software environment, the Linux container build script can simply install the Pixi environment.
* Using GitHub Actions workflows allows for the build process to happen automatically through CI/CD.

:::
