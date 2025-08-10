---
title: "Conda packages"
teaching: 30
exercises: 15
---

::: questions

* What is a conda package?

:::

::: objectives

* Learn about conda package structure

:::

## Conda packages

In a previous episode we learned that Pixi can control conda packages, but what _is_ a conda package?
[Conda packages](https://docs.conda.io/projects/conda/en/stable/user-guide/concepts/packages.html) (`.conda` files) are language agnostic file archives that contain built code distributions.
This is quite powerful, as it allows for arbitrary code to be built for any target platform and then packaged with its metadata.
When a conda package is downloaded and then unpacked with a conda package management tool (e.g. Pixi, conda, mamba) the only thing that needs to be done to "install" that package is just copy the package's file directory tree to the base of the environment's directory tree.
Package contents are also simple; they can only contain files and symbolic links.

### Exploring package structure

To better understand conda packages and the environment directory tree structure they exist in, let's make a new Pixi project and look at the project environment directory tree structure.

```bash
pixi init ~/pixi-cuda-lesson/dir-structure
cd ~/pixi-cuda-lesson/dir-structure
```
```output
✔ Created /home/<username>/pixi-cuda-lesson/dir-structure/pixi.toml
```

To help visualize this on the command line we'll use the `tree` program (Linux and macOS), which we'll install as a global utility from conda-forge using [`pixi global`](https://pixi.sh/latest/global_tools/introduction/).

::: group-tab

### Unix and Windows Terminal

```bash
pixi global install tree
```
```output
└── tree: 2.2.1 (installed)
    └─ exposes: tree
```

### Windows PowerShell

Windows [PowerShell already has a `tree`](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree) command, but is less powerful and configurable than the Unix `tree`.
It provides no way to limit the tree depth, so we'll use other commands instead like

```powershell
ls -d <depth>
```

:::

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

::: group-tab

### Unix and Windows Terminal

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

### Windows PowerShell

```powershell
ls | fw -col 1
```
```output
.gitattributes
.gitignore
pixi.toml
```

:::

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

::: group-tab

### Unix and Windows Terminal

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

### Windows PowerShell

```powershell
ls | fw -col 1
```
```output
.gitattributes
.gitignore
.pixi
pixi.lock
pixi.toml
```

:::

Let's now use `tree` to look at the directory structure of the Pixi project starting at the same directory where the `pixi.toml` manifest file is.

::: group-tab

### Unix and Windows Terminal

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

### Windows PowerShell

```powershell
ls -d 3 .pixi\
```
```output
...
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           6/15/2025  7:34 AM                conda-meta
d----           6/15/2025  7:34 AM                DLLs
d----           6/15/2025  7:34 AM                etc
d----           6/15/2025  7:34 AM                include
d----           6/15/2025  7:34 AM                Lib
d----           6/15/2025  7:34 AM                Library
d----           6/15/2025  7:34 AM                libs
d----           6/15/2025  7:34 AM                Scripts
d----           6/15/2025  7:34 AM                share
d----           6/15/2025  7:34 AM                Tools
...
```

:::

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

::: group-tab

### Linux

```bash
pixi list
```
```output
Package           Version    Build               Size       Kind   Source
_libgcc_mutex     0.1        conda_forge         2.5 KiB    conda  https://conda.anaconda.org/conda-forge/
_openmp_mutex     4.5        2_gnu               23.1 KiB   conda  https://conda.anaconda.org/conda-forge/
bzip2             1.0.8      h4bc722e_7          246.9 KiB  conda  https://conda.anaconda.org/conda-forge/
ca-certificates   2025.4.26  hbd8a1cb_0          148.7 KiB  conda  https://conda.anaconda.org/conda-forge/
ld_impl_linux-64  2.43       h1423503_5          654.9 KiB  conda  https://conda.anaconda.org/conda-forge/
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
python            3.13.5     hf636f53_101_cp313  31.7 MiB   conda  https://conda.anaconda.org/conda-forge/
python_abi        3.13       7_cp313             6.8 KiB    conda  https://conda.anaconda.org/conda-forge/
readline          8.2        h8c095d6_2          275.9 KiB  conda  https://conda.anaconda.org/conda-forge/
tk                8.6.13     noxft_hd72426e_102  3.1 MiB    conda  https://conda.anaconda.org/conda-forge/
tzdata            2025b      h78e105d_0          120.1 KiB  conda  https://conda.anaconda.org/conda-forge/
```

### macOS

```bash
pixi list
```
```output
Package          Version    Build               Size       Kind   Source
bzip2            1.0.8      h99b78c6_7          120 KiB    conda  https://conda.anaconda.org/conda-forge/
ca-certificates  2025.6.15  hbd8a1cb_0          147.5 KiB  conda  https://conda.anaconda.org/conda-forge/
libexpat         2.7.0      h286801f_0          64.2 KiB   conda  https://conda.anaconda.org/conda-forge/
libffi           3.4.6      h1da3d7d_1          38.9 KiB   conda  https://conda.anaconda.org/conda-forge/
liblzma          5.8.1      h39f12f2_2          90.1 KiB   conda  https://conda.anaconda.org/conda-forge/
libmpdec         4.0.0      h5505292_0          70.1 KiB   conda  https://conda.anaconda.org/conda-forge/
libsqlite        3.50.1     h3f77e49_0          880.1 KiB  conda  https://conda.anaconda.org/conda-forge/
libzlib          1.3.1      h8359307_2          45.3 KiB   conda  https://conda.anaconda.org/conda-forge/
ncurses          6.5        h5e97a16_3          778.3 KiB  conda  https://conda.anaconda.org/conda-forge/
openssl          3.5.0      h81ee809_1          2.9 MiB    conda  https://conda.anaconda.org/conda-forge/
python           3.13.5     h81fe080_101_cp313  12.3 MiB   conda  https://conda.anaconda.org/conda-forge/
python_abi       3.13       7_cp313             6.8 KiB    conda  https://conda.anaconda.org/conda-forge/
readline         8.2        h1d1bf99_2          246.4 KiB  conda  https://conda.anaconda.org/conda-forge/
tk               8.6.13     h892fb3f_2          3 MiB      conda  https://conda.anaconda.org/conda-forge/
tzdata           2025b      h78e105d_0          120.1 KiB  conda  https://conda.anaconda.org/conda-forge/
```

### Windows

```bash
pixi list
```
```output
Package          Version       Build               Size       Kind   Source
bzip2            1.0.8         h2466b09_7          53.6 KiB   conda  https://conda.anaconda.org/conda-forge/
ca-certificates  2025.4.26     h4c7d964_0          149.4 KiB  conda  https://conda.anaconda.org/conda-forge/
libexpat         2.7.0         he0c23c2_0          137.6 KiB  conda  https://conda.anaconda.org/conda-forge/
libffi           3.4.6         h537db12_1          43.9 KiB   conda  https://conda.anaconda.org/conda-forge/
liblzma          5.8.1         h2466b09_2          102.5 KiB  conda  https://conda.anaconda.org/conda-forge/
libmpdec         4.0.0         h2466b09_0          86.6 KiB   conda  https://conda.anaconda.org/conda-forge/
libsqlite        3.50.1        h67fdade_0          1 MiB      conda  https://conda.anaconda.org/conda-forge/
libzlib          1.3.1         h2466b09_2          54.2 KiB   conda  https://conda.anaconda.org/conda-forge/
openssl          3.5.0         ha4e3fda_1          8.6 MiB    conda  https://conda.anaconda.org/conda-forge/
python           3.13.5        h261c0b1_101_cp313  16.1 MiB   conda  https://conda.anaconda.org/conda-forge/
python_abi       3.13          7_cp313             6.8 KiB    conda  https://conda.anaconda.org/conda-forge/
tk               8.6.13        h2c6b04d_2          3.3 MiB    conda  https://conda.anaconda.org/conda-forge/
tzdata           2025b         h78e105d_0          120.1 KiB  conda  https://conda.anaconda.org/conda-forge/
ucrt             10.0.22621.0  h57928b3_1          546.6 KiB  conda  https://conda.anaconda.org/conda-forge/
vc               14.3          h2b53caa_26         17.5 KiB   conda  https://conda.anaconda.org/conda-forge/
vc14_runtime     14.42.34438   hfd919c2_26         733.1 KiB  conda  https://conda.anaconda.org/conda-forge/
```
:::

We can download an individual conda package manually using a tool like `curl`.
Let's download the particular [`python` conda package](https://anaconda.org/conda-forge/python) from where it is hosted on [conda-forge's Anaconda.org organization](https://anaconda.org/conda-forge)

::: group-tab

### Linux

```bash
curl -sLO https://anaconda.org/conda-forge/python/3.13.3/download/linux-64/python-3.13.3-hf636f53_101_cp313.conda
ls *.conda
```
```output
python-3.13.3-hf636f53_101_cp313.conda
```

### macOS

```bash
curl -sLO https://anaconda.org/conda-forge/python/3.13.3/download/osx-arm64/python-3.13.3-h81fe080_101_cp313.conda
ls *.conda
```
```output
python-3.13.3-h81fe080_101_cp313.conda
```

### Windows

```powershell
iwr -Uri "https://anaconda.org/conda-forge/python/3.13.3/download/win-64/python-3.13.3-h261c0b1_101_cp313.conda" -OutFile "python-3.13.3-h261c0b1_101_cp313.conda"
ls *.conda
```
```output
python-3.13.3-h261c0b1_101_cp313.conda
```
:::

`.conda` is probably not a file extension that you've seen before, but you are probably very familiar with the actual archive compression format.
`.conda` files are `.zip` files that have been renamed, but we can use the same utilities to interact with them as we would with `.zip` files.

::: group-tab

### Linux

```bash
unzip python-3.13.3-hf636f53_101_cp313.conda -d output
```
```output
Archive:  python-3.13.3-hf636f53_101_cp313.conda
 extracting: output/metadata.json
 extracting: output/pkg-python-3.13.3-hf636f53_101_cp313.tar.zst
 extracting: output/info-python-3.13.3-hf636f53_101_cp313.tar.zst
```

### macOS

```bash
unzip python-3.13.3-h81fe080_101_cp313.conda -d output
```
```output
Archive:  python-3.13.3-h81fe080_101_cp313.conda
 extracting: output/metadata.json
 extracting: output/pkg-python-3.13.3-h81fe080_101_cp313.tar.zst
 extracting: output/info-python-3.13.3-h81fe080_101_cp313.tar.zst
```

### Windows

```powershell
Expand-Archive "python-3.13.3-h261c0b1_101_cp313.conda" "output"
```
```output
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           6/15/2025  4:57 PM                pkg
d----           6/15/2025  4:57 PM                pkg
-a---            1/1/1980 12:00 AM         133799 info-python-3.13.3-h261c0b1_101_cp313.tar.zst
-a---           4/14/2025  8:38 PM             31 metadata.json
-a---            1/1/1980 12:00 AM       16480111 pkg-python-3.13.3-h261c0b1_101_cp313.tar.zst
```
:::

We see that the `.conda` archive contained package format metadata (`metadata.json`) as well as two other tar archives compressed with the Zstandard compression algorithm (`.tar.zst`).
We can uncompress them manually with `tar`

```bash
cd output
mkdir -p pkg
tar --zstd -xvf pkg-python-*.tar.zst --directory pkg
```

and then look at the uncompressed directory tree with `tree`

::: group-tab

### Linux

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

### macOS

```bash
tree -L 2 pkg
```
```output
pkg
├── bin
│   ├── idle3 -> idle3.13
│   ├── idle3.13
│   ├── pydoc -> pydoc3.13
│   ├── pydoc3 -> pydoc3.13
│   ├── pydoc3.13
│   ├── python -> python3.13
│   ├── python3 -> python3.13
│   ├── python3-config -> python3.13-config
│   ├── python3.1 -> python3.13
│   ├── python3.13
│   └── python3.13-config
├── include
│   └── python3.13
├── info
│   └── licenses
├── lib
│   ├── libpython3.13.dylib
│   ├── pkgconfig
│   └── python3.13
└── share
    └── man
```

### Windows

```powershell
ls -d 2 pkg\
```

:::

So we can see that the directory structure of the conda package

::: group-tab

### Linux

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

### macOS

```bash
ls -1p pkg/lib/
```
```output
libpython3.13.dylib
pkgconfig/
python3.13/
```

### Windows

```powershell
ls pkg | fw -col 1
```
```output
DLLs
include
info
Lib
libs
Scripts
Tools
LICENSE_PYTHON.txt
python.exe
python.pdb
python3.dll
python313.dll
python313.pdb
pythonw.exe
pythonw.pdb
```

:::

is reflected in the directory tree of the Pixi environment with the package installed

::: group-tab

### Linux

```bash
cd ..
ls -1a .pixi/envs/default/lib/libpython*
```
```output
.pixi/envs/default/lib/libpython3.13.so
.pixi/envs/default/lib/libpython3.13.so.1.0
.pixi/envs/default/lib/libpython3.so
```

### macOS

```bash
cd ..
ls -1a .pixi/envs/default/lib/libpython*
```
```output
.pixi/envs/default/lib/libpython3.13.dylib
```

### Windows

```powershell
cd ..
ls .pixi\envs\default\python*.dll | fw -col 1
```
```output
python3.dll
python313.dll
```

:::

::: discussion

Hopefully this seems straightforward and unmagical &mdash; because it is!
Conda package structure is simple and easy to understand because it builds off of basic file system structures and doesn't try to invent new systems.
It is important to demystify what is happening with the directory tree structure though so that we keep in our minds that our tools are just manipulating files.

:::

::: challenge

## Exploring conda-forge

As of 2025 [conda-forge](https://conda-forge.org/) has over 28,500 packages on it.
Go to the conda-forge package list website (https://conda-forge.org/packages/) and try to find three packages that you use in your research, and three packages from your scientific field that are more niche.

::: solution

## Some packages

Research packages:

* [`jax`](https://github.com/conda-forge/jax-feedstock)
* [`boost-histogram`](https://github.com/conda-forge/boost-histogram-feedstock)
* [`awkward`](https://github.com/conda-forge/awkward-feedstock)

Niche particle physics packages:

* [`siscone`](https://github.com/conda-forge/siscone-feedstock)
* [`iminuit`](https://github.com/conda-forge/iminuit-feedstock)
* [`stanhf`](https://github.com/conda-forge/stanhf-feedstock)

:::
:::

::: checklist

## Further conda package references

[Wolf Vollprecht](https://github.com/wolfv) of prefix.dev GmbH has written blog posts on topics covered in this section that provide an excellent overview and summary.
You are highly encouraged to read them!

* [What is a Conda package, actually?](https://prefix.dev/blog/what-is-a-conda-package) (2025-06-11)
* [Virtual Packages in the Conda ecosystem](https://prefix.dev/blog/virtual-packages-in-the-conda-ecosystem) (2025-06-18)
* [What linking means when installing a Conda package](https://prefix.dev/blog/what-linking-means-when-installing-a-conda-package) (2025-07-17)

:::

::: keypoints

* Conda packages are specially named `.zip` files that contain files and symbolic links structured in a directory tree.

:::
