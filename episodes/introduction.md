---
title: "Reproducible Research"
teaching: 10
exercises: 8
---

::: questions

* What does it mean to be "reproducible"?
* How is "reproducibility" different than "reuse"?

:::

::: objectives

* Describe the terms "reproducibility" and "reuse" as they relate to research computing
* Describe what is needed for a computational environment to be reproducible.

:::

## Introduction

Modern scientific analyses are complex software and logistical workflows that may span multiple software environments and require heterogenous software and computing infrastructure.
Scientific researchers need to use these tools to be able to do their research, and to ensure the validity of their work, which can be difficult.
Scientific software enables all of this work to happen, but software isn't a static resource &mdash; software is continually developed, revised, and released, which can introduce breaking changes or subtle computational differences in outputs and results.
Having the software you're using change without you intending it from day-to-day, run-to-run, or on different machines is problematic when trying to do high quality research.
These changes can cause software bugs, errors in scientific results, and make findings unreproducible.
All of these things are not desirable!

::: callout

When discussing "software" in this lesson we will primarily be meaning open source software that is openly developed.
However, there are situations in which software might (for good reason) be:

* Closed development with open source release artifacts
* Closed development and closed source with public binary distributions
* Closed development and closed source with proprietary licenses

:::

::: challenge

## Challenges to reproducible research?

Take 3 minutes to discuss the following questions in small groups.

**What are other challenges to doing reproducible research?**

Think about all aspects of research computing &mdash; data, hardware, and software &mdash; from collecting and cleaning the data through analysis and visualization to publishing your methods and results?

Have you even inherited a project from a previous contributor?
Or gone back to a previous project more than couple months later and struggled to get back into it?
What issues did you come across?

::: solution

## Possible answers

There are many! Here are some you might have thought of:

* (Not having) Access to data
* Required software packages be removed from mutable package indexes
* Unreproducible builds of software that isn't packaged and distributed on public package indexes
* Analysis code not being under version control
* Not having any environment definition configuration files

:::
:::

## Computational reproducibility

"Reproducible" research can mean many things and is a multipronged problem.
This lesson will focus primarily on computational reproducibility.
Like all forms of reproducibility, there are multiple "levels" of reproducibility.
For this lesson we will focus on "full" reproducibility, meaning that reproducible software environments will:

* Be defined through user readable and writable configuration files.
* Have machine produced "lock files" with a full definition of all software in the environment.
* Specify the target computer platforms (operating system and architecture) for all environments solved.
* Have the resolution of a platform's environments be machine agnostic (e.g. macOS platform machines can solve environments for Linux platforms).
* Have the software packages defined in the environments be published on immutable public package indexes.

### Hardware accelerated environments

::: challenge

## Challenges with reproducible hardware accelerated environments

What are possible challenges of reproducible hardware accelerated environments?
If you are using GPUs for a machine learing application, what challenges have you run into with running your code?

::: solution

## Possible answers

Here are some you might have thought of:

* Installing hardware acceleration drivers and libraries on the machine with the GPU
* Knowing what drivers are supported for the available GPUs
* Providing instructions to install the same drivers and libraries on multiple computing platforms
* Having the "deployment" machine's resources and environment where the analysis is done match the "development" machine's environment

:::
:::

Software that involves hardware acceleration on computing resources like GPUs requires additional information to be provided for full computational reproducibility.
In addition to the computer platform, information about the hardware acceleration device, its supported drivers, and compatible hardware accelerated versions of the software in the environment (GPU enabled builds) are required.
Traditionally this has been very difficult to do, but multiple recent technological advancements (made possible by social agreements and collaborations) in the scientific open source world now provide solutions to these problems.


::: challenge

##  What is computataional reproduciblity?

Do you think "computational reproducibility" means that the exact same numeric results should be achieved every time? Discuss with your table.

::: solution

Not necessarily.
Even though the computational software environment is identical there are things that can change between runs of software that could slightly change numerical results (e.g. random number generation seeds, file read order, machine entropy).
This isn't necessarily a problem, and in general one should be more concerned with getting answers that make sense within application uncertainties than matching down to machine precision.

Did your the individuals in your group agree?

:::
:::

## Computational reproducibility vs. scientific reuse

Aiming for computational reproducibility is the first step to making scientific research more beneficial to us.
For the purposes of a single analysis this should be the primary goal.
However, just because a software environment is fully reproducible does not mean that the research is automatically reusable.
Imagine a software analyis fully documented but with the data file names hard-coded in.
The whole analysis can be reproduced but needs to be refactored to use other data.

**Reuse** allows for the tools and components of the scientific workflow to be composable tools that can interoperate together to
create a workflow.
The steps of the workflow might exist in radically different computational environments and require different software, or different versions of the same software tools.
Given these demands, reproducible computational software environments are the next step toward fully reusable scientific workflows.

This lesson will focus on computational reproducibility of hardware accelerated scientific workflows (e.g. machine learning).
Scientifically reusable analysis workflows are a more extensive topic, but this lesson will link to references on the topic.

::: challenge

## The challenges of creating reproducible and reuseble worflos

What personal challenges have you encountered to making your own research practices reproducible and reusable?

::: solution

## Possible answers

* Technical expertise in reproducibility technologies
* Time to learn new tools
* Balancing reproducibility concerns with using tools the entire research team can understand

:::
:::

In addition to the computational issue that arise with creating reproduicble and reusable workflows, it takes time and effort to design analyses with these in mind.
This lesson aims to teach you tools that will make creating reproducible and reusable workflows easier.

::: keypoints

* Modern scientific research is complex and requires software environments.
* Computational reproducibility helps to enable reproducible science.
* Reproducible computational software environments that use hardware acceleration require additional information.
* New technologies make all of these processes easier.
* Reproducible computational software environments are a first step toward fully reusable scientific workflows.

:::
