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

TODO: Download a conda package first and unpack it!

To better understand conda packages and the environment directory tree structure they exist in, let's look at the directory tree for the example Pixi project that we made.
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

Let's now use `tree` to look at the directory structure of the example Pixi project starting at the same directory where the `pixi.toml` manifest file is.

```bash
tree -L 3 .pixi/
```
```output
.pixi/
└── envs
    └── default
        ├── bin
        ├── conda-meta
        ├── etc
        ├── include
        ├── lib
        ├── man
        ├── sbin
        ├── share
        ├── ssl
        ├── x86_64-conda_cos6-linux-gnu
        └── x86_64-conda-linux-gnu

13 directories, 0 files
```

We see that the `default` environment that Pixi created for has the standard directory tree layout for a Unix machine

* `bin` for binary executables
* `include` for header files
* `lib` for binary libraries
* `man` for manual pages
* `share` for files that other libraries or applications might need from the installed programs

::: keypoints

* CUDA

:::
