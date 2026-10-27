---
title: "CUDA conda packages"
teaching: 30
exercises: 15
---

::: questions

* What is CUDA?
* How can I use CUDA enabled conda packages?

:::

::: objectives

* Understand how CUDA can be used with conda packages
* Create a hardware accelerated environment

:::

## CUDA

CUDA (Compute Unified Device Architecture) [is a parallel computing platform and programming model developed by NVIDIA for general computing on graphical processing units (GPUs)](https://developer.nvidia.com/cuda-zone).
The CUDA ecosystem provides software development kits (SDKs) with APIs to CUDA that allow for software developers to write hardware accelerated programs with CUDA in various languages for NVIDIA GPUs.
CUDA supports a number of languages including C, C++, Fortran, Python, and Julia.
While there are other types of hardware acceleration development platforms, as of 2025 CUDA is the most abundant platform for scientific computing that uses GPUs and effectively the default choice for major machine learning libraries and applications.

CUDA is closed source and proprietary to NVIDIA, which means that NVIDIA has historically limited the download access of the CUDA toolkits and drivers to registered NVIDIA developers (while keeping the software free (monetarily) to use).
CUDA then required a [multi-step installation process](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/) with manual steps and decisions based on the target platform and particular CUDA version.
This meant that when CUDA enabled environments were set up on a particular machine they were powerful and optimized, but brittle to change and could easily be broken if system wide updates (like for security fixes) occurred.
CUDA software environments were bespoke and not many scientists understood how to construct and curate them.

## CUDA on conda-forge

In [late 2018](https://github.com/conda-forge/conda-forge.github.io/issues/687) to better support the scientific developer community, NVIDIA started to release components of the CUDA toolkits on the [`nvidia` conda channel](https://anaconda.org/nvidia).
This provided the first access to start to create conda environments where the versions of different CUDA tools could be directly specified and downloaded.
However, all of this work was being done internally in NVIDIA and as it was on a separate channel it was less visible and it still required additional knowledge to work with.
In [2023](https://youtu.be/WgKwlGgVzYE?si=hfyAo6qLma8hnJ-N), NVIDIA's open source team began to move the release of CUDA conda packages from the `nvidia` channel to conda-forge, making it easier to discover and allowing for community support.
With significant advancements in system driver specification support, CUDA 12 became the first version of CUDA to be released as conda packages through conda-forge and included all CUDA libraries from the [CUDA compiler `nvcc`](https://github.com/conda-forge/cuda-nvcc-feedstock) to the [CUDA development libraries](https://github.com/conda-forge/cuda-libraries-dev-feedstock).
They also released [CUDA metapackages](https://github.com/conda-forge/cuda-feedstock/) that allowed users to easily describe the version of CUDA they required (e.g. `cuda-version=12.5`) and the CUDA conda packages they wanted (e.g. `cuda`).
This significantly improved the ability for researchers to easily create CUDA accelerated computing environments.

This is all possible via use of the `__cuda` [virtual conda package](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-virtual.html), which is determined automatically by conda package managers from the hardware information associated with the machine the package manager is installed on.

With Pixi, a user can get this information with [`pixi info`](https://pixi.sh/latest/advanced/explain_info_command/), which could have output that looks something like

```bash
pixi info
```
```output
System
------------
       Pixi version: 0.50.2
           Platform: linux-64
   Virtual packages: __unix=0=0
                   : __linux=6.8.0=0
                   : __glibc=2.35=0
                   : __cuda=12.9=0
                   : __archspec=1=skylake
          Cache dir: /home/<username>/.cache/rattler/cache
       Auth storage: /home/<username>/.rattler/credentials.json
   Config locations: No config files found

Global
------------
            Bin dir: /home/<username>/.pixi/bin
    Environment dir: /home/<username>/.pixi/envs
       Manifest dir: /home/<username>/.pixi/manifests/pixi-global.toml

```

## CUDA use with Pixi

To be able to effectively use CUDA conda packages with Pixi, we declare the CUDA support we need on the [platforms of the workspace](https://pixi.prefix.dev/latest/workspace/multi_platform_configuration/).
A platform in a Pixi workspace can be given as just a conda platform name (e.g. `linux-64`), or as a "rich platform" that also specifies the **minimum** system specifications, given as virtual packages, needed to install and run the workspace's environments on that platform.

To do this for CUDA, we give the platform a name and add the minimum supported CUDA version (based on the host machine's NVIDIA driver API) we want to support.

Example:

```toml
[workspace]
platforms = [{ name = "linux-64-cuda", platform = "linux-64", cuda = "12" }]  # Replace "12" with the specific CUDA version you intend to use
```

This ensures that packages depending on `__cuda >= {version}` are resolved correctly for the `linux-64-cuda` platform.
The name of the platform is what we use to refer to it in Pixi commands and in the workspace manifest.

To demonstrate this a bit more explicitly, we can create a minimal project

```bash
pixi init ~/pixi-cuda-lesson/cuda-example
cd ~/pixi-cuda-lesson/cuda-example
```
```output
✔ Created /home/<username>/pixi-cuda-lesson/cuda-example/pixi.toml
```

where we add a `linux-64-cuda` platform that requires CUDA 12

```bash
pixi workspace platform add --cuda 12 linux-64-cuda=linux-64
```
```output
✔ Added linux-64-cuda
```

and remove the `linux-64` platform that doesn't require CUDA, so that all of the workspace's Linux environments will use CUDA

```bash
pixi workspace platform remove linux-64
```
```output
✔ Removed linux-64
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-example"
platforms = [{ name = "linux-64-cuda", platform = "linux-64", cuda = "12" }]
version = "0.1.0"

[tasks]

[dependencies]
```

and then install the [`cuda-version` metapackage](https://github.com/conda-forge/cuda-version-feedstock/blob/main/recipe/README.md)

```bash
pixi add "cuda-version 12.9.*"
```
```output
✔ Added cuda-version 12.9.*
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-example"
platforms = [{ name = "linux-64-cuda", platform = "linux-64", cuda = "12" }]
version = "0.1.0"

[tasks]

[dependencies]
cuda-version = "12.9.*"
```

If we look at the metadata installed by the `cuda-version` package (the only thing it does)

```bash
cat .pixi/envs/default/conda-meta/cuda-version-*.json
```
```json
{
  "build": "h4f385c5_3",
  "build_number": 3,
  "constrains": [
    "cudatoolkit 12.9|12.9.*",
    "__cuda >=12"
  ],
  "depends": [],
  "license": "LicenseRef-NVIDIA-End-User-License-Agreement",
  "md5": "b6d5d7f1c171cbd228ea06b556cfa859",
  "name": "cuda-version",
  "noarch": "generic",
  "sha256": "5f5f428031933f117ff9f7fcc650e6ea1b3fef5936cf84aa24af79167513b656",
  "size": 21578,
  "subdir": "noarch",
  "timestamp": 1746134436166,
  "version": "12.9",
  "fn": "cuda-version-12.9-h4f385c5_3.conda",
  "url": "https://conda.anaconda.org/conda-forge/noarch/cuda-version-12.9-h4f385c5_3.conda",
  "channel": "https://conda.anaconda.org/conda-forge/",
  "extracted_package_dir": "/home/<username>/.cache/rattler/cache/pkgs/cuda-version-12.9-h4f385c5_3",
  "files": [],
  "paths_data": {
    "paths_version": 1,
    "paths": []
  },
  "link": {
    "source": "/home/<username>/.cache/rattler/cache/pkgs/cuda-version-12.9-h4f385c5_3",
    "type": 1
  }
}
```

we see that it now enforces constraints on the versions of `cudatoolkit` that can be installed as well as the required `__cuda` virtual package provided by the system

```json
{
  ...
  "constrains": [
    "cudatoolkit 12.9|12.9.*",
    "__cuda >=12"
  ],
  ...
}
```

::: callout

## Use the `feature` table to solve environments that your platform doesn't support

CUDA is supported only by NVIDIA GPUs, which means that macOS operating system platforms (`osx-64`, `osx-arm64`) can't support it.
Similarly, if your machine doesn't have an NVIDIA GPU, then the `__cuda` virtual package won't exist and installs of CUDA packages will fail.
However, there are many situations in which you want to **solve an environment for a platform that you don't have** and we can do this for CUDA as well.

If we make the Pixi workspace multiplatform

```bash
pixi workspace platform add osx-arm64 win-64
```
```output
✔ Added osx-arm64
✔ Added win-64
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-example"
platforms = [{ name = "linux-64-cuda", platform = "linux-64", cuda = "12" }, "osx-arm64", "win-64"]
version = "0.1.0"

[tasks]

[dependencies]
cuda-version = "12.9.*"
```

We can then use Pixi's [platform specific `target` tables](https://pixi.sh/latest/reference/pixi_manifest/#the-target-table) to add dependencies for an environment to only a specific platform.
So, if we know that a dependency only exists for platform <platform> then we can have Pixi add it for only that platform with

```bash
pixi add --platform <platform> <dependency>
```

:::

This now means that if we ask for any CUDA enabled packages, we will get ones that are built to support `cudatoolkit` `v12.9.*`

```bash
pixi add --platform linux-64-cuda cuda
```
```output
✔ Added cuda >=12.9.2,<13
Added these only for platform(s): linux-64-cuda
```

```bash
pixi list --platform linux-64-cuda cuda
```
```output
Name                         Version  Build             Size  Kind   Source
cuda                         12.9.2   ha804496_0   27.18 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-cccl_linux-64           12.9.27  ha770c72_0    1.10 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-command-line-tools      12.9.2   ha770c72_0   20.48 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-compiler                12.9.2   hbad6d8a_0   20.64 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-crt-dev_linux-64        12.9.86  ha770c72_2   92.03 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-crt-tools               12.9.86  ha770c72_2   28.46 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-cudart                  12.9.79  h5888daf_0   22.70 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-cudart-dev              12.9.79  h5888daf_0   23.13 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-cudart-dev_linux-64     12.9.79  h3f2d84a_0  380.02 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-cudart-static           12.9.79  h5888daf_0   22.74 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-cudart-static_linux-64  12.9.79  h3f2d84a_0    1.10 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-cudart_linux-64         12.9.79  h3f2d84a_0  192.63 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-cuobjdump               12.9.82  hffce074_1  239.33 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-cupti                   12.9.79  h676940d_2    1.77 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-cupti-dev               12.9.79  h676940d_2    4.03 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-cuxxfilt                12.9.82  hffce074_1  211.39 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-driver-dev              12.9.79  h5888daf_0   22.54 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-driver-dev_linux-64     12.9.79  h3f2d84a_0   36.83 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-gdb                     12.9.79  hba53cbc_4    4.46 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-libraries               12.9.2   ha770c72_0   20.50 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-libraries-dev           12.9.2   ha770c72_0   20.61 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nsight                  12.9.79  h7938cbb_0  113.20 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvcc                    12.9.86  hcdd1206_6   24.88 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvcc-dev_linux-64       12.9.86  he91c749_2   27.46 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvcc-impl               12.9.86  h85509e4_2   26.58 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvcc-tools              12.9.86  he02047a_2   26.11 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvcc_linux-64           12.9.86  he0b4e1d_6   26.93 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvdisasm                12.9.88  hffce074_1    5.26 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvml-dev                12.9.79  hffce074_1  139.99 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvprof                  12.9.79  hcf8d014_0    2.51 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvprune                 12.9.82  hffce074_1   69.29 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvrtc                   12.9.86  hecca717_1   64.06 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvrtc-dev               12.9.86  hecca717_1   35.96 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvtx                    12.9.79  hecca717_1   28.75 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvvm-dev_linux-64       12.9.86  ha770c72_2   26.46 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvvm-impl               12.9.86  h4bc722e_2   20.43 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvvm-tools              12.9.86  h4bc722e_2   23.12 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-nvvp                    12.9.79  hbd13f7d_0  104.27 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-opencl                  12.9.19  h5888daf_0   30.03 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-opencl-dev              12.9.19  h5888daf_0   95.13 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-profiler-api            12.9.79  h7938cbb_1   23.11 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-runtime                 12.9.2   ha804496_0   20.39 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-sanitizer-api           12.9.79  h10ca0ad_1    9.05 MiB  conda  https://conda.anaconda.org/conda-forge
cuda-toolkit                 12.9.2   ha804496_0   20.44 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-tools                   12.9.2   ha770c72_0   20.26 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-version                 12.9     h4f385c5_3   21.07 KiB  conda  https://conda.anaconda.org/conda-forge
cuda-visual-tools            12.9.2   ha770c72_0   20.37 KiB  conda  https://conda.anaconda.org/conda-forge
```

To "prove" that this works, we can ask for the CUDA enabled version of PyTorch

```bash
pixi add --platform linux-64-cuda pytorch-gpu
```
```output
✔ Added pytorch-gpu >=2.14.1,<3
Added these only for platform(s): linux-64-cuda
```
```bash
pixi list --platform linux-64-cuda torch
```
```output
Name         Version  Build                                 Size  Kind   Source
libtorch     2.14.1   cuda129_mkl_h546cc0b_300        795.16 MiB  conda  https://conda.anaconda.org/conda-forge
pytorch      2.14.1   cuda129_mkl_py312_h0509a7e_300   27.71 MiB  conda  https://conda.anaconda.org/conda-forge
pytorch-gpu  2.14.1   cuda129_mkl_h0d04637_300         54.62 KiB  conda  https://conda.anaconda.org/conda-forge
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-example"
platforms = [{ name = "linux-64-cuda", platform = "linux-64", cuda = "12" }, "osx-arm64", "win-64"]
version = "0.1.0"

[tasks]

[dependencies]
cuda-version = "12.9.*"

[target.linux-64-cuda.dependencies]
cuda = ">=12.9.2,<13"
pytorch-gpu = ">=2.14.1,<3"
```

::: caution

## Redundancy in example

Note that we added the `cuda` package here for demonstration purposes, but we didn't _need_ to as it would already be installed as a dependency of `pytorch-gpu`.

```bash
cat .pixi/envs/default/conda-meta/pytorch-gpu-*.json
```
```json
{
  "build": "cuda129_mkl_h43a4b0b_304",
  "build_number": 304,
  "depends": [
    "pytorch 2.7.1 cuda*_mkl*304"
  ],
  "license": "BSD-3-Clause",
  "license_family": "BSD",
  "md5": "e374ee50f7d5171d82320bced8165e85",
  "name": "pytorch-gpu",
  "sha256": "af54e6535619f4e484d278d015df6ea67622e2194f78da2c0541958fc3d83d18",
  "size": 48008,
  "subdir": "linux-64",
  "timestamp": 1753886159800,
  "version": "2.7.1",
  "fn": "pytorch-gpu-2.7.1-cuda129_mkl_h43a4b0b_304.conda",
  "url": "https://conda.anaconda.org/conda-forge/linux-64/pytorch-gpu-2.7.1-cuda129_mkl_h43a4b0b_304.conda",
  "channel": "https://conda.anaconda.org/conda-forge/",
  "extracted_package_dir": "/home/<username>/.cache/rattler/cache/pkgs/pytorch-gpu-2.7.1-cuda129_mkl_h43a4b0b_304",
  "files": [],
  "paths_data": {
    "paths_version": 1,
    "paths": []
  },
  "link": {
    "source": "/home/<username>/.cache/rattler/cache/pkgs/pytorch-gpu-2.7.1-cuda129_mkl_h43a4b0b_304",
    "type": 1
  }
}
```

:::

and **if on a machine that supports the `linux-64-cuda` platform** check that it can see and find GPUs

```python
# torch_detect_GPU.py
import torch
from torch import cuda

if __name__ == "__main__":
    if torch.backends.cuda.is_built():
        print(f"PyTorch build CUDA version: {torch.version.cuda}")
        print(f"PyTorch build cuDNN version: {torch.backends.cudnn.version()}")
        print(f"PyTorch build NCCL version: {torch.cuda.nccl.version()}")

        print(f"\nNumber of GPUs found on system: {cuda.device_count()}")

    if cuda.is_available():
        print(f"\nActive GPU index: {cuda.current_device()}")
        print(f"Active GPU name: {cuda.get_device_name(cuda.current_device())}")
    elif torch.backends.mps.is_available():
        mps_device = torch.device("mps")
        print(f"PyTorch has active GPU: {mps_device}")
    else:
        print(f"PyTorch has no active GPU")
```

```bash
pixi run python torch_detect_GPU.py
```
```output
PyTorch build CUDA version: 12.9
PyTorch build cuDNN version: 91100
PyTorch build NCCL version: (2, 27, 7)

Number of GPUs found on system: 1

Active GPU index: 0
Active GPU name: NVIDIA GeForce RTX 4060 Laptop GPU
```

::: challenge

## Multi-environment Pixi workspaces

Create a new Pixi workspace that:

* Contains an environment for `linux-64`, `osx-arm64`, and `win-64` that supports the CPU version of PyTorch
* Contains an environment for `linux-64` and `win-64` that supports the GPU version of PyTorch
* Supports CUDA `v12`

::: solution

Create a new workspace

```bash
pixi init ~/pixi-cuda-lesson/cuda-exercise
cd ~/pixi-cuda-lesson/cuda-exercise
```
```output
✔ Created /home/<username>/pixi-cuda-lesson/cuda-exercise/pixi.toml
```

Add support for all the target platforms

```bash
pixi workspace platform add linux-64 osx-arm64 win-64
```
```output
✔ Added linux-64
✔ Added osx-arm64
✔ Added win-64
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-exercise"
platforms = ["linux-64", "osx-arm64", "win-64"]
version = "0.1.0"

[tasks]

[dependencies]
```

Let's first add `pytorch-cpu` to a `cpu` feature

```bash
pixi add --feature cpu pytorch-cpu
```
```output
✔ Added pytorch-cpu
Added these only for feature: cpu
```

and then create a `cpu` environment that contains the `cpu` feature

```bash
pixi workspace environment add --feature cpu cpu
```
```output
✔ Added environment cpu
```

and then instantiate the `pytorch-cpu` package with a particular version and solve through [`pixi upgrade`](https://pixi.sh/dev/reference/cli/pixi/upgrade/) (or could re-add the package to the feature)

```bash
pixi upgrade --feature cpu pytorch-cpu
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-exercise"
platforms = ["linux-64", "osx-arm64", "win-64"]
version = "0.1.0"

[tasks]

[dependencies]

[feature.cpu.dependencies]
pytorch-cpu = ">=2.14.1,<3"

[environments]
cpu = ["cpu"]
```

Now, for the GPU environment, add platforms for `linux-64` and `win-64` that require CUDA 12 to the `gpu` feature

```bash
pixi workspace platform add --cuda 12 --feature gpu linux-64-cuda=linux-64
pixi workspace platform add --cuda 12 --feature gpu win-64-cuda=win-64
```
```output
✔ Added linux-64-cuda to feature 'gpu'
✔ Added win-64-cuda to feature 'gpu'
```

(Pixi will also warn that the `gpu` feature isn't used in any environment yet, which we will fix next.)
This adds the new platforms to the workspace `platforms` list, and restricts the `gpu` feature to only those platforms.

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-exercise"
platforms = ["linux-64", "osx-arm64", "win-64", { name = "linux-64-cuda", platform = "linux-64", cuda = "12" }, { name = "win-64-cuda", platform = "win-64", cuda = "12" }]
version = "0.1.0"

[tasks]

[dependencies]

[feature.cpu.dependencies]
pytorch-cpu = ">=2.14.1,<3"

[feature.gpu]
platforms = ["linux-64-cuda", "win-64-cuda"]

[environments]
cpu = ["cpu"]
```

and create a `gpu` environment with the `gpu` feature

```bash
pixi workspace environment add --feature gpu gpu
```
```output
✔ Added environment gpu
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-exercise"
platforms = ["linux-64", "osx-arm64", "win-64", { name = "linux-64-cuda", platform = "linux-64", cuda = "12" }, { name = "win-64-cuda", platform = "win-64", cuda = "12" }]
version = "0.1.0"

[tasks]

[dependencies]

[feature.cpu.dependencies]
pytorch-cpu = ">=2.14.1,<3"

[feature.gpu]
platforms = ["linux-64-cuda", "win-64-cuda"]

[environments]
cpu = ["cpu"]
gpu = ["gpu"]
```

then add the `pytorch-gpu` package to the `gpu` feature.
As the `gpu` feature is restricted to the `linux-64-cuda` and `win-64-cuda` platforms, we don't need to specify the platforms again.

```bash
pixi add --feature gpu pytorch-gpu
```
```output
✔ Added pytorch-gpu >=2.13.0,<3
Added these only for feature: gpu
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-exercise"
platforms = ["linux-64", "osx-arm64", "win-64", { name = "linux-64-cuda", platform = "linux-64", cuda = "12" }, { name = "win-64-cuda", platform = "win-64", cuda = "12" }]
version = "0.1.0"

[tasks]

[dependencies]

[feature.cpu.dependencies]
pytorch-cpu = ">=2.14.1,<3"

[feature.gpu]
platforms = ["linux-64-cuda", "win-64-cuda"]

[feature.gpu.dependencies]
pytorch-gpu = ">=2.13.0,<3"

[environments]
cpu = ["cpu"]
gpu = ["gpu"]
```

One can check the environment differences

```bash
pixi list --environment cpu
pixi list --environment gpu
```

and activate shells with different environments loaded

```bash
pixi shell --environment cpu
```

So in 22 lines of TOML

```bash
wc -l pixi.toml
```
```output
22 pixi.toml
```

we created separate CPU and GPU computational environments that are now fully reproducible with the associated `pixi.lock`!

:::
:::


::: callout

## Version Control

On a **new branch** in your repository, add and commit the files from this episode.

```bash
git add cuda-example/pixi.* cuda-example/.git*
git add cuda-exercise/pixi.* cuda-exercise/.git*
git commit
```

Then push your branch to your remote on GitHub

```bash
git push -u origin HEAD
```

and make a pull request to merge your changes into your remote's default branch.

:::

::: checklist

## Further CUDA and GPU references

If you would also like a useful summary of different things related to CUDA, check out Modal's summary website of CUDA focused GPU concepts.

* [GPU Glossary](https://modal.com/gpu-glossary), by Modal

:::

::: keypoints

* The `cuda-version` metapackage can be used to specify constraints on the versions of the `__cuda` virtual package and `cudatoolkit`.
* Pixi can specify a minimum required CUDA version for a platform with rich platforms in the workspace `platforms` list.
* Pixi can solve environments for platforms that are not the system platform.
* NVIDIA's open source team and the conda-forge community support the CUDA conda packages on conda-forge.
* The [`cuda` metapackage](https://github.com/conda-forge/cuda-feedstock/tree/main/recipe) is the primary place to go for user documentation on the CUDA conda packages.

:::
