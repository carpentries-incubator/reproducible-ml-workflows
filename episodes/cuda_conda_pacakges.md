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


::: keypoints

* CUDA

:::
