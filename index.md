---
site: sandpaper::sandpaper_site
---

Scientific researchers need reproducible software environments for complex applications that can run across heterogeneous computing platforms.
For machine learning on GPUs, a working environment also depends on the hardware acceleration libraries, like CUDA, that the software was built against.
Without a precise definition of every package in an environment, rerunning a workflow on a different machine, or on the same machine in the future, can give different results or fail.

This lesson teaches technologies and best practices for creating fully reproducible, multi-platform software environments for machine learning workflows, including environments that use CUDA on NVIDIA GPUs.
Using [Pixi](https://pixi.prefix.dev/), you will define software environments with declarative manifest files, resolve and lock all dependencies to their exact version and digest, and resolve environments for Linux, macOS, and Windows from any of these platforms.
You will then build these environments into Linux containers with automated GitHub Actions workflows, and use them to run machine learning training on high-throughput computing (HTC) and high-performance computing (HPC) systems.

The lesson is designed to be taught as a three-day workshop, where each day has a half day of instruction from the lesson material, followed by a half day of interactive work sessions in which participants apply what they learned to their own research projects with the help of the instruction team.
The lesson does not teach machine learning concepts.
Instead, it focuses on the tools and methods that make existing machine learning workflows reproducible.

:::  prereq

## Prerequisites

This lesson is aimed at researchers who already have basic experience with scientific software development, including:

* Navigating file systems that follow the Filesystem Hierarchy Standard of Unix-like systems.
* Using version control with Git.
* Programming in a language such as Python or C++.
* A working understanding of the goals of machine learning.

Experience with Linux containers and continuous integration and continuous delivery (CI/CD) systems is not required, but is beneficial.

Access to an NVIDIA GPU, and to an HTC or HPC system, is needed to run some of the examples, but you can follow the lesson without them.
See the [Setup](learners/setup.md) page for details.

:::

The source code for the lesson is archived on Zenodo and is citable from the following DOI: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17537698.svg){alt="Zenodo DOI badge for 10.5281/zenodo.17537698"}](https://doi.org/10.5281/zenodo.17537698)
