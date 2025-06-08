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

::: keypoints

* CUDA

:::
