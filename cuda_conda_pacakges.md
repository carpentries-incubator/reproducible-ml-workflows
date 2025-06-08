---
title: "Conda packages and CUDA"
teaching: 30
exercises: 15
---

::: questions

* What is a conda package?
* What is CUDA?
* How can I use CUDA enabled conda packages?

:::

::: objectives

* Learn about conda package structure
* Understand how CUDA can be used with conda packages
* Create a hardware accelerated environment

:::

## Conda packages

In the last episode we learned that Pixi can control conda packages, but what _is_ a conda package?
[Conda packages](https://docs.conda.io/projects/conda/en/stable/user-guide/concepts/packages.html) (`.conda` files) are language agnostic file archives that contain built code distributions.
This is quite powerful, as it allows for arbitrary code to be built for any target platform and then packaged with its metadata.
When a conda package is downloaded and then unpacked with a conda package management tool (e.g. Pixi, conda, mamba) the only thing that needs to be done to "install" that package is just copy the package's file directory tree to the base of the environment's directory tree.
Package contents are also simple; they can only contain files and symbolic links.

### Exploring package structure

To better understand conda packages and the environment directory tree structure they exist in, let's make a new Pixi project and look at the project environment directory tree structure.

```bash
pixi init ~/pixi-lesson/dir-structure
cd ~/pixi-lesson/dir-structure
```
```output
✔ Created /home/<username>/pixi-lesson/dir-structure/pixi.toml
```

To help visualize this on the command line we'll use the `tree` program (Linux and macOS), which we'll install as a global utility from conda-forge using [`pixi global`](https://pixi.sh/latest/global_tools/introduction/).

```bash
pixi global install tree
```
```output
└── tree: 2.2.1 (installed)
    └─ exposes: tree
```

Pixi has now installed `tree` for us in a custom environment under `~/.pixi/envs/tree/` and then exposed the `tree` command globally by placing `tree` on our shell's `PATH` at `~/.pixi/bin/tree`.
This now means that for any new terminal shell we open, `tree` will be available to use.

At the moment our Pixi project manifest is empty

```toml
[workspace]
channels = ["conda-forge"]
name = "dir-structure"
platforms = ["linux-64"]
version = "0.1.0"

[tasks]

[dependencies]
```

and so is our directory tree

```bash
ls -1ap
```
```output
./
../
.gitattributes
.gitignore
pixi.toml

```

Let's add a dependency to our project to change that

```bash
pixi add python
```
```output
✔ Added python >=3.13.3,<3.14
```

which now gives us an update Pixi manifest

```toml
[workspace]
channels = ["conda-forge"]
name = "dir-structure"
platforms = ["linux-64"]
version = "0.1.0"

[tasks]

[dependencies]
python = ">=3.13.3,<3.14"
```

and the start of a directory tree with the `.pixi/` directory

```bash
ls -1ap
```
```output
./
../
.gitattributes
.gitignore
.pixi/
pixi.lock
pixi.toml
```

Let's now use `tree` to look at the directory structure of the Pixi project starting at the same directory where the `pixi.toml` manifest file is.

```bash
tree -L 3 .pixi/
```
```output
.pixi/
└── envs
    └── default
        ├── bin
        ├── conda-meta
        ├── include
        ├── lib
        ├── man
        ├── share
        ├── ssl
        ├── x86_64-conda_cos6-linux-gnu
        └── x86_64-conda-linux-gnu

11 directories, 0 files
```

We see that the `default` environment that Pixi created has the standard directory tree layout for operating systems following the [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/fhs.shtml) (FHS) (e.g. Unix machines)

* `bin`: for binary executables
* `include`: for include files (e.g. header files in C/C++)
* `lib`: for binary libraries
* `share`: for files and data that other libraries or applications might need from the installed programs

as well as some less common ones related to system administration

* `man:` for manual pages
* `sbin`: for system binaries
* `ssl`: for SSL (Secure Sockets Layer) certificates to provide secure encryption when connecting to websites

as well as other directories that are specific to conda packages

* `conda-meta`: for metadata for all installed conda packages
* `x86_64-conda_cos6-linux-gnu` and `x86_64-conda-linux-gnu`: for platform specific tools (like linkers) &mdash; this will vary depending on your operating system

How did this directory tree get here?
It is a result of all the files that were in the conda packages we downloaded and installed as dependencies of Python.

```bash
pixi list
```
```output
Package           Version    Build               Size       Kind   Source
_libgcc_mutex     0.1        conda_forge         2.5 KiB    conda  https://conda.anaconda.org/conda-forge/
_openmp_mutex     4.5        2_gnu               23.1 KiB   conda  https://conda.anaconda.org/conda-forge/
bzip2             1.0.8      h4bc722e_7          246.9 KiB  conda  https://conda.anaconda.org/conda-forge/
ca-certificates   2025.4.26  hbd8a1cb_0          148.7 KiB  conda  https://conda.anaconda.org/conda-forge/
ld_impl_linux-64  2.43       h712a8e2_4          655.5 KiB  conda  https://conda.anaconda.org/conda-forge/
libexpat          2.7.0      h5888daf_0          72.7 KiB   conda  https://conda.anaconda.org/conda-forge/
libffi            3.4.6      h2dba641_1          56.1 KiB   conda  https://conda.anaconda.org/conda-forge/
libgcc            15.1.0     h767d61c_2          809.7 KiB  conda  https://conda.anaconda.org/conda-forge/
libgcc-ng         15.1.0     h69a702a_2          33.8 KiB   conda  https://conda.anaconda.org/conda-forge/
libgomp           15.1.0     h767d61c_2          442 KiB    conda  https://conda.anaconda.org/conda-forge/
liblzma           5.8.1      hb9d3cd8_2          110.2 KiB  conda  https://conda.anaconda.org/conda-forge/
libmpdec          4.0.0      hb9d3cd8_0          89 KiB     conda  https://conda.anaconda.org/conda-forge/
libsqlite         3.50.1     hee588c1_0          898.3 KiB  conda  https://conda.anaconda.org/conda-forge/
libuuid           2.38.1     h0b41bf4_0          32.8 KiB   conda  https://conda.anaconda.org/conda-forge/
libzlib           1.3.1      hb9d3cd8_2          59.5 KiB   conda  https://conda.anaconda.org/conda-forge/
ncurses           6.5        h2d0b736_3          870.7 KiB  conda  https://conda.anaconda.org/conda-forge/
openssl           3.5.0      h7b32b05_1          3 MiB      conda  https://conda.anaconda.org/conda-forge/
python            3.13.3     hf636f53_101_cp313  31.7 MiB   conda  https://conda.anaconda.org/conda-forge/
python_abi        3.13       7_cp313             6.8 KiB    conda  https://conda.anaconda.org/conda-forge/
readline          8.2        h8c095d6_2          275.9 KiB  conda  https://conda.anaconda.org/conda-forge/
tk                8.6.13     noxft_hd72426e_102  3.1 MiB    conda  https://conda.anaconda.org/conda-forge/
tzdata            2025b      h78e105d_0          120.1 KiB  conda  https://conda.anaconda.org/conda-forge/
```

We can download an individual conda package manually using `curl`.
Let's ensure you have `curl` first

```bash
pixi global install curl
```
```output
└── curl: 8.14.1 (installed)
    └─ exposes: curl
```

and then use it to download the particular [`python` conda package](https://anaconda.org/conda-forge/python) from where it is hosted on [conda-forge's Anaconda.org organization](https://anaconda.org/conda-forge)

```bash
curl -sLO https://anaconda.org/conda-forge/python/3.13.3/download/linux-64/python-3.13.3-hf636f53_101_cp313.conda
ls *.conda
```
```output
python-3.13.3-hf636f53_101_cp313.conda
```

`.conda` is probably not a file extension that you've seen before, but you are probably very familiar with the actual archive compression format.
`.conda` files are `.zip` files that have been renamed, but we can use the same utilities to interact with them as we would with `.zip` files.

```bash
unzip python-3.13.3-hf636f53_101_cp313.conda -d output
```
```output
Archive:  python-3.13.3-hf636f53_101_cp313.conda
 extracting: output/metadata.json
 extracting: output/pkg-python-3.13.3-hf636f53_101_cp313.tar.zst
 extracting: output/info-python-3.13.3-hf636f53_101_cp313.tar.zst
```

We see that the `.conda` archive contained package format metadata (`metadata.json`) as well as two other tar archives compressed with the Zstandard compression algorithm (`.tar.zst`).
We can uncompress them manually with `tar`

```bash
cd output
mkdir -p pkg
tar --zstd -xvf pkg-python-3.13.3-hf636f53_101_cp313.tar.zst --directory pkg
```

and then look at the uncompressed directory tree with `tree`

```bash
tree -L 2 pkg
```
```output
pkg
├── bin
│   ├── idle3 -> idle3.13
│   ├── idle3.13
│   ├── pydoc -> pydoc3.13
│   ├── pydoc3 -> pydoc3.13
│   ├── pydoc3.13
│   ├── python -> python3.13
│   ├── python3 -> python3.13
│   ├── python3.1 -> python3.13
│   ├── python3.13
│   ├── python3.13-config
│   └── python3-config -> python3.13-config
├── include
│   └── python3.13
├── info
│   └── licenses
├── lib
│   ├── libpython3.13.so -> libpython3.13.so.1.0
│   ├── libpython3.13.so.1.0
│   ├── libpython3.so
│   ├── pkgconfig
│   └── python3.13
└── share
    ├── man
    └── python_compiler_compat
```

So we can see that the directory structure of the conda package

```bash
ls -1p pkg/lib/
```
```output
libpython3.13.so
libpython3.13.so.1.0
libpython3.so
pkgconfig/
python3.13/
```

is reflected in the directory tree of the Pixi environment with the package installed

```bash
cd ..
ls -1a .pixi/envs/default/lib/libpython*
```
```output
.pixi/envs/default/lib/libpython3.13.so
.pixi/envs/default/lib/libpython3.13.so.1.0
.pixi/envs/default/lib/libpython3.so
```

::: discussion

Hopefully this seems straightforward and unmagical &mdash; because it is!
Conda package structure is simple and easy to understand because it builds off of basic file system structures and doesn't try to invent new systems.
It is important to demystify what is happening with the directory tree structure though so that we keep in our minds that our tools are just manipulating files.

:::

## CUDA

CUDA (Compute Unified Device Architecture) [is a parallel computing platform and programming model developed by NVIDIA for general computing on graphical processing units (GPUs)](https://developer.nvidia.com/cuda-zone).
The CUDA ecosystem provides software developer software development kits (SDK) with APIs to CUDA that allow for software developers to write hardware accelerated programs with CUDA in various languages for NVIDIA GPUs.
CUDA supports a number of languages including C, C++, Fortran, Python, and Julia.
While there are other types of hardware acceleration development platforms, as of 2025 CUDA is the most abundant platform for scientific computing that uses GPUs and effectively the default choice for major machine learning libraries and applications.

CUDA is closed source and proprietary to NVIDIA, which means that NVIDIA has historically limited the download access of the CUDA toolkits and drivers to registered NVIDIA developers (while keeping the software free (monetarily) to use).
CUDA then required a [multi-step installation process](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/) with manual steps and decisions based on the target platform and particular CUDA version.
This meant that when CUDA enabled environments were setup on a particular machine they were powerful and optimized, but brittle to change and could easily be broken if system wide updates (like for security fixes) occurred.
CUDA software environments were bespoke and not many scientists understood how to construct and curate them.

### CUDA on conda-forge

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
       Pixi version: 0.48.0
           Platform: linux-64
   Virtual packages: __unix=0=0
                   : __linux=6.8.0=0
                   : __glibc=2.35=0
                   : __cuda=12.4=0
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

### CUDA use with Pixi

To be able to effectively use CUDA conda packages with Pixi, we make use of Pixi's [system requirement workspace table](https://pixi.sh/latest/workspace/system_requirements/), which specifies the **minimum**  system specifications needed to install and run a Pixi workspace's environments.

To do this for CUDA, we just add the minimum supported CUDA version (based on the host machine's NVIDIA driver API) we want to support to the table.

Example:

```toml
[system-requirements]
cuda = "12"  # Replace "12" with the specific CUDA version you intend to use
```

This ensures that packages depending on `__cuda >= {version}` are resolved correctly.

To demonstrate this a bit more explicitly, we can create a minimal project

```bash
pixi init ~/pixi-lesson/cuda-example
cd ~/pixi-lesson/cuda-example
```
```output
✔ Created /home/<username>/pixi-lesson/cuda-example/pixi.toml
```

where we specify a `cuda` system requirement

```bash
pixi workspace system-requirements add cuda 12
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-example"
platforms = ["linux-64"]
version = "0.1.0"

[system-requirements]
cuda = "12"

[tasks]

[dependencies]
```

and then install the [`cuda-version` metapacakge](https://github.com/conda-forge/cuda-version-feedstock/blob/main/recipe/README.md)

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
platforms = ["linux-64"]
version = "0.1.0"

[system-requirements]
cuda = "12"

[tasks]

[dependencies]
cuda-version = "12.9.*"
```

If we look at the metadata installed by the `cuda-version` package (the only thing it does)

```bash
$ cat .pixi/envs/default/conda-meta/cuda-version-*.json
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

This now means that if we ask for any CUDA enbabled packages, we will get ones that are built to support `cudatoolkit` `v12.9.*`

```bash
pixi add cuda
```
```output
✔ Added cuda >=12.9.1,<13
```

```bash
pixi list cuda
```
```output
Package                      Version  Build       Size       Kind   Source
cuda                         12.9.1   ha804496_0  26.7 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-cccl_linux-64           12.9.27  ha770c72_0  1.1 MiB    conda  https://conda.anaconda.org/conda-forge/
cuda-command-line-tools      12.9.1   ha770c72_0  20 KiB     conda  https://conda.anaconda.org/conda-forge/
cuda-compiler                12.9.1   hbad6d8a_0  20.2 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-crt-dev_linux-64        12.9.86  ha770c72_1  92.2 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-crt-tools               12.9.86  ha770c72_1  28.2 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-cudart                  12.9.79  h5888daf_0  22.7 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-cudart-dev              12.9.79  h5888daf_0  23.1 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-cudart-dev_linux-64     12.9.79  h3f2d84a_0  380 KiB    conda  https://conda.anaconda.org/conda-forge/
cuda-cudart-static           12.9.79  h5888daf_0  22.7 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-cudart-static_linux-64  12.9.79  h3f2d84a_0  1.1 MiB    conda  https://conda.anaconda.org/conda-forge/
cuda-cudart_linux-64         12.9.79  h3f2d84a_0  192.6 KiB  conda  https://conda.anaconda.org/conda-forge/
cuda-cuobjdump               12.9.82  hbd13f7d_0  237.5 KiB  conda  https://conda.anaconda.org/conda-forge/
cuda-cupti                   12.9.79  h9ab20c4_0  1.8 MiB    conda  https://conda.anaconda.org/conda-forge/
cuda-cupti-dev               12.9.79  h9ab20c4_0  4.4 MiB    conda  https://conda.anaconda.org/conda-forge/
cuda-cuxxfilt                12.9.82  hbd13f7d_0  211.4 KiB  conda  https://conda.anaconda.org/conda-forge/
cuda-driver-dev              12.9.79  h5888daf_0  22.5 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-driver-dev_linux-64     12.9.79  h3f2d84a_0  36.8 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-gdb                     12.9.79  ha677faa_0  378.2 KiB  conda  https://conda.anaconda.org/conda-forge/
cuda-libraries               12.9.1   ha770c72_0  20 KiB     conda  https://conda.anaconda.org/conda-forge/
cuda-libraries-dev           12.9.1   ha770c72_0  20.1 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nsight                  12.9.79  h7938cbb_0  113.2 MiB  conda  https://conda.anaconda.org/conda-forge/
cuda-nvcc                    12.9.86  hcdd1206_1  24.3 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvcc-dev_linux-64       12.9.86  he91c749_1  13.8 MiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvcc-impl               12.9.86  h85509e4_1  26.6 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvcc-tools              12.9.86  he02047a_1  26.2 MiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvcc_linux-64           12.9.86  he0b4e1d_1  26.2 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvdisasm                12.9.88  hbd13f7d_0  5.3 MiB    conda  https://conda.anaconda.org/conda-forge/
cuda-nvml-dev                12.9.79  hbd13f7d_0  139.1 KiB  conda  https://conda.anaconda.org/conda-forge/
cuda-nvprof                  12.9.79  hcf8d014_0  2.5 MiB    conda  https://conda.anaconda.org/conda-forge/
cuda-nvprune                 12.9.82  hbd13f7d_0  69.3 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvrtc                   12.9.86  h5888daf_0  64.1 MiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvrtc-dev               12.9.86  h5888daf_0  35.7 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvtx                    12.9.79  h5888daf_0  28.6 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvvm-dev_linux-64       12.9.86  ha770c72_1  26.3 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvvm-impl               12.9.86  he02047a_1  20.4 MiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvvm-tools              12.9.86  he02047a_1  23.1 MiB   conda  https://conda.anaconda.org/conda-forge/
cuda-nvvp                    12.9.79  hbd13f7d_0  104.3 MiB  conda  https://conda.anaconda.org/conda-forge/
cuda-opencl                  12.9.19  h5888daf_0  30 KiB     conda  https://conda.anaconda.org/conda-forge/
cuda-opencl-dev              12.9.19  h5888daf_0  95.1 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-profiler-api            12.9.79  h7938cbb_0  23 KiB     conda  https://conda.anaconda.org/conda-forge/
cuda-runtime                 12.9.1   ha804496_0  19.9 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-sanitizer-api           12.9.79  hcf8d014_0  8.6 MiB    conda  https://conda.anaconda.org/conda-forge/
cuda-toolkit                 12.9.1   ha804496_0  20 KiB     conda  https://conda.anaconda.org/conda-forge/
cuda-tools                   12.9.1   ha770c72_0  19.9 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-version                 12.9     h4f385c5_3  21.1 KiB   conda  https://conda.anaconda.org/conda-forge/
cuda-visual-tools            12.9.1   ha770c72_0  19.9 KiB   conda  https://conda.anaconda.org/conda-forge/
```

To "prove" that this works, we can ask for the CUDA enabled version of PyTorch

```bash
pixi add pytorch-gpu
```
```output
✔ Added pytorch-gpu >=2.7.0,<3
```
```bash
 pixi list torch
```
```output
Package      Version  Build                           Size       Kind   Source
libtorch     2.7.0    cuda126_mkl_h99b69db_300        566.9 MiB  conda  https://conda.anaconda.org/conda-forge/
pytorch      2.7.0    cuda126_mkl_py312_h30b5a27_300  27.8 MiB   conda  https://conda.anaconda.org/conda-forge/
pytorch-gpu  2.7.0    cuda126_mkl_ha999a5f_300        46.1 KiB   conda  https://conda.anaconda.org/conda-forge/
```

```toml
[workspace]
channels = ["conda-forge"]
name = "cuda-example"
platforms = ["linux-64"]
version = "0.1.0"

[system-requirements]
cuda = "12"

[tasks]

[dependencies]
cuda-version = "12.9.*"
cuda = ">=12.9.1,<13"
pytorch-gpu = ">=2.7.0,<3"
```

and check that it can see and find GPUs

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
PyTorch build CUDA version: 12.6
PyTorch build cuDNN version: 91001
PyTorch build NCCL version: (2, 26, 5)

Number of GPUs found on system: 1

Active GPU index: 0
Active GPU name: NVIDIA GeForce RTX 4060 Laptop GPU
```

::: keypoints

* Conda packages are specially named `.zip` files that contain files and symbolic links structured in a directory tree.
* The `cuda-version` metapackage can be used to specify constrains on the versions of the `__cuda` virtual package and `cudatoolkit`.
* Pixi can specify a minimum required CUDA version with the `[system-requirements]` table.
* NVIDIA's open source team and the conda-forge community support the CUDA conda packages on conda-forge.
* The [`cuda` metapackage](https://github.com/conda-forge/cuda-feedstock/tree/main/recipe) is the primary place to go for user documetnation on the CUDA conda packages.

:::
