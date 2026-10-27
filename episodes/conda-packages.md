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
When a conda package is downloaded and then unpacked with a conda package management tool (e.g. Pixi, conda, mamba) the only thing that needs to be done to "install" that package is to just copy the package's file directory tree to the base of the environment's directory tree.
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
✔ Added python >=3.15.2,<3.16
```

which now gives us an updated Pixi manifest

```toml
[workspace]
channels = ["conda-forge"]
name = "dir-structure"
platforms = ["linux-64"]
version = "0.1.0"

[tasks]

[dependencies]
python = ">=3.15.2,<3.16"
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

### Linux

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
        └── x86_64-conda-linux-gnu

11 directories, 0 files
```

### macOS

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
        └── ssl

10 directories, 0 files
```

### Windows

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

* `man`: for manual pages
* `sbin`: for system binaries
* `ssl`: for SSL (Secure Sockets Layer) certificates to provide secure encryption when connecting to websites

as well as other directories that are specific to conda packages

* `conda-meta`: for metadata for all installed conda packages
* `x86_64-conda-linux-gnu`: for platform specific tools (like linkers) &mdash; this will vary depending on your operating system

How did this directory tree get here?
It is a result of all the files that were in the conda packages we downloaded and installed as dependencies of Python.

::: group-tab

### Linux

```bash
pixi list
```
```output
Installed for: linux-64
Name              Version       Build                       Size  Kind   Source
_openmp_mutex     4.5           20_gnu                 28.27 KiB  conda  https://conda.anaconda.org/conda-forge
bzip2             1.0.8         hda65f42_10           251.77 KiB  conda  https://conda.anaconda.org/conda-forge
ca-certificates   2026.10.23    hbd8a1cb_0            127.01 KiB  conda  https://conda.anaconda.org/conda-forge
ld_impl_linux-64  2.46.1        default_hbd61a6d_103  724.72 KiB  conda  https://conda.anaconda.org/conda-forge
libedit           3.1.20260512  pl5321h373387f_0      132.69 KiB  conda  https://conda.anaconda.org/conda-forge
libexpat          2.9.0         hd2095e1_0             77.04 KiB  conda  https://conda.anaconda.org/conda-forge
libffi            3.7.0         h81df57d_1             66.41 KiB  conda  https://conda.anaconda.org/conda-forge
libgcc            16.2.0        ha9f2e26_7              1.01 MiB  conda  https://conda.anaconda.org/conda-forge
libgomp           16.2.0        he0feb66_7            625.55 KiB  conda  https://conda.anaconda.org/conda-forge
liblzma           5.8.3         hb03c661_1            110.35 KiB  conda  https://conda.anaconda.org/conda-forge
libmpdec          4.0.0         hb03c661_2             90.58 KiB  conda  https://conda.anaconda.org/conda-forge
libsqlite         3.54.1        h0737f62_101          957.51 KiB  conda  https://conda.anaconda.org/conda-forge
libuuid           2.42.4        hcfc3c73_0             33.63 KiB  conda  https://conda.anaconda.org/conda-forge
libzlib           1.3.2         h25fd6f3_3             62.22 KiB  conda  https://conda.anaconda.org/conda-forge
ncurses           6.6           hdb14827_1            889.84 KiB  conda  https://conda.anaconda.org/conda-forge
openssl           3.6.5         h781a0a9_0              3.05 MiB  conda  https://conda.anaconda.org/conda-forge
python            3.15.2        h6e52b48_100_cp315     27.97 MiB  conda  https://conda.anaconda.org/conda-forge
python_abi        3.15          9_cp315                 6.64 KiB  conda  https://conda.anaconda.org/conda-forge
tk                8.6.13        noxft_h1df4ec4_4        3.40 MiB  conda  https://conda.anaconda.org/conda-forge
tzdata            2026e         h5d301ff_0            116.41 KiB  conda  https://conda.anaconda.org/conda-forge
zstd              1.5.7         hb78ec9c_7            587.21 KiB  conda  https://conda.anaconda.org/conda-forge
```

### macOS

```bash
pixi list
```
```output
Installed for: osx-arm64
Name             Version       Build                     Size  Kind   Source
bzip2            1.0.8         h4e30115_10         122.04 KiB  conda  https://conda.anaconda.org/conda-forge
ca-certificates  2026.10.23    hbd8a1cb_0          127.01 KiB  conda  https://conda.anaconda.org/conda-forge
libedit          3.1.20260512  pl5321h26f1114_0    105.97 KiB  conda  https://conda.anaconda.org/conda-forge
libexpat         2.9.0         h6111c0a_0           68.05 KiB  conda  https://conda.anaconda.org/conda-forge
libffi           3.7.0         h47dc5ef_1           42.61 KiB  conda  https://conda.anaconda.org/conda-forge
liblzma          5.8.3         h8088a28_1           89.57 KiB  conda  https://conda.anaconda.org/conda-forge
libmpdec         4.0.0         h84a0fba_2           71.57 KiB  conda  https://conda.anaconda.org/conda-forge
libsqlite        3.54.1        h34a968b_101        927.20 KiB  conda  https://conda.anaconda.org/conda-forge
libzlib          1.3.2         h8088a28_3           46.70 KiB  conda  https://conda.anaconda.org/conda-forge
ncurses          6.6           he64c551_1          785.45 KiB  conda  https://conda.anaconda.org/conda-forge
openssl          3.6.5         h55eecbc_0            2.97 MiB  conda  https://conda.anaconda.org/conda-forge
python           3.15.2        h2e4dbab_100_cp315   12.80 MiB  conda  https://conda.anaconda.org/conda-forge
python_abi       3.15          9_cp315               6.64 KiB  conda  https://conda.anaconda.org/conda-forge
tk               8.6.13        hbeba79b_4            3.19 MiB  conda  https://conda.anaconda.org/conda-forge
tzdata           2026e         h5d301ff_0          116.41 KiB  conda  https://conda.anaconda.org/conda-forge
zstd             1.5.7         hf451053_7          423.52 KiB  conda  https://conda.anaconda.org/conda-forge
```

### Windows

```bash
pixi list
```
```output
Installed for: win-64
Name             Version       Build                     Size  Kind   Source
bzip2            1.0.8         h0ad9c76_10          54.61 KiB  conda  https://conda.anaconda.org/conda-forge
ca-certificates  2026.10.23    h4c7d964_0          127.37 KiB  conda  https://conda.anaconda.org/conda-forge
libexpat         2.9.0         hac47afa_0           71.27 KiB  conda  https://conda.anaconda.org/conda-forge
libffi           3.7.0         h3d046cb_1           48.82 KiB  conda  https://conda.anaconda.org/conda-forge
liblzma          5.8.3         hfd05255_1          103.33 KiB  conda  https://conda.anaconda.org/conda-forge
libmpdec         4.0.0         hfd05255_2           87.02 KiB  conda  https://conda.anaconda.org/conda-forge
libsqlite        3.54.1        hf5d6505_101          1.27 MiB  conda  https://conda.anaconda.org/conda-forge
libzlib          1.3.2         hfd05255_3           57.16 KiB  conda  https://conda.anaconda.org/conda-forge
openssl          3.6.5         hf411b9b_0            8.97 MiB  conda  https://conda.anaconda.org/conda-forge
python           3.15.2        h53f6dd8_100_cp315   17.72 MiB  conda  https://conda.anaconda.org/conda-forge
python_abi       3.15          9_cp315               6.64 KiB  conda  https://conda.anaconda.org/conda-forge
tk               8.6.13        h967ab96_4            3.61 MiB  conda  https://conda.anaconda.org/conda-forge
tzdata           2026e         h5d301ff_0          116.41 KiB  conda  https://conda.anaconda.org/conda-forge
ucrt             10.0.26100.0  h57928b3_0          678.41 KiB  conda  https://conda.anaconda.org/conda-forge
vc               14.5          ha367084_41          20.88 KiB  conda  https://conda.anaconda.org/conda-forge
vc14_runtime     14.51.36247   habf1de7_41         749.96 KiB  conda  https://conda.anaconda.org/conda-forge
vcomp14          14.51.36247   habf1de7_41         152.26 KiB  conda  https://conda.anaconda.org/conda-forge
zstd             1.5.7         h534d264_7          378.45 KiB  conda  https://conda.anaconda.org/conda-forge
```
:::

We can download an individual conda package manually using a tool like `curl`.
Let's download the particular [`python` conda package](https://anaconda.org/conda-forge/python) from where it is hosted on [conda-forge's Anaconda.org organization](https://anaconda.org/conda-forge)

::: group-tab

### Linux

```bash
curl -sLO https://anaconda.org/conda-forge/python/3.13.5/download/linux-64/python-3.13.5-hec9711d_102_cp313.conda
ls *.conda
```
```output
python-3.13.5-hec9711d_102_cp313.conda
```

### macOS

```bash
curl -sLO https://anaconda.org/conda-forge/python/3.13.5/download/osx-arm64/python-3.13.5-hf3f3da0_102_cp313.conda
ls *.conda
```
```output
python-3.13.5-hf3f3da0_102_cp313.conda
```

### Windows

```powershell
iwr -Uri "https://anaconda.org/conda-forge/python/3.13.5/download/win-64/python-3.13.5-h7de537c_102_cp313.conda" -OutFile "python-3.13.5-h7de537c_102_cp313.conda"
ls *.conda
```
```output
python-3.13.5-h7de537c_102_cp313.conda
```
:::

`.conda` is probably not a file extension that you've seen before, but you are probably very familiar with the actual archive compression format.
`.conda` files are `.zip` files that have been renamed, but we can use the same utilities to interact with them as we would with `.zip` files.

::: group-tab

### Linux

```bash
unzip python-3.13.5-hec9711d_102_cp313.conda -d output
```
```output
Archive:  python-3.13.5-hec9711d_102_cp313.conda
 extracting: output/metadata.json
 extracting: output/pkg-python-3.13.5-hec9711d_102_cp313.tar.zst
 extracting: output/info-python-3.13.5-hec9711d_102_cp313.tar.zst
```

### macOS

```bash
unzip python-3.13.5-hf3f3da0_102_cp313.conda -d output
```
```output
Archive:  python-3.13.5-hf3f3da0_102_cp313.conda
 extracting: output/metadata.json
 extracting: output/pkg-python-3.13.5-hf3f3da0_102_cp313.tar.zst
 extracting: output/info-python-3.13.5-hf3f3da0_102_cp313.tar.zst
```

### Windows

```powershell
Expand-Archive "python-3.13.5-h7de537c_102_cp313.conda" "output"
```
```output
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           8/11/2025  2:11 AM                pkg
d----           8/11/2025  2:11 AM                pkg
-a---            1/1/1980 12:00 AM         133451 info-python-3.13.5-h7de537c_102_cp313.tar.zst
-a---           6/16/2025  8:25 AM             31 metadata.json
-a---            1/1/1980 12:00 AM       16691645 pkg-python-3.13.5-h7de537c_102_cp313.tar.zst
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

12 directories, 14 files
```

### macOS

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
│   ├── libpython3.13.dylib
│   ├── pkgconfig
│   └── python3.13
└── share
    └── man

11 directories, 12 files
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

As of August 2025 [conda-forge](https://conda-forge.org/) has over 29,000 packages on it.
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
