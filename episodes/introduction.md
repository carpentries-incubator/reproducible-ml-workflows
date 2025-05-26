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

* Understand the concepts of reproducibility and reuse
* Be able to describe what is needed for a computational environment to be reproducible.

:::

## Introduction

Modern scientific analyses are complex software and logistical workflows that may span multiple software environments and require heterogenous software and computing infrastructure.
Scientific researchers need to keep track of all of this to be able to do their research, and to ensure the validity of their work, which can be difficult.
Scientific software enables all of this work to happen, but software isn't a static resource &mdash; software is continually developed, revised, and released, which can introduce large breaking changes or subtle computational differences in outputs and results.
Having the software you're using change without you intending it from day-to-day, run-to-run, or on different machines is problematic when trying to do high quality research and can cause software bugs, errors in scientific results, and make findings unreproducible.
All of these things are not desirable!

::: callout

When discussing "software" in this lesson we will primarily be meaning open source software that is openly developed.
However, there are situations in which software might (for good reason) be:

* Closed development with open source release artifacts
* Closed development and closed source with public binary distributions
* Closed development and closed source with proprietary licenses

:::

::: instructor

Ask the participants to discuss the question in small groups of 2 to 4 people at their table for 3 minutes and then to share their group's thoughts.

:::

::: challenge

## What are other challenges to reproducible research?

::: solution

## Possible answers

There are many! Here are some you might have thought of:

* (Not having) Access to data
* Required software packages be removed from mutable package indexes
* Unreproducible builds of software that isn't packaged and distributed on public package indexes
* Analysis code not being under version control
* Not having any environment definition configuration files

What did you come up with?

:::
:::

## Computational Reproducibility

"Reproducible" research can mean many things and is a multipronged problem.
This lesson will focus primarily on computational reproducibility.
Like all forms of reproducibility, there are multiple "levels" of reproducibility.
For this lesson we will focus on "full" reproducibility, meaning that reproducible software environments will:

* Be defined through high level user configuration files.
* Have machine produced hash level lock files with a full definition of all software in the environment.
* Specify target computer platforms for all environments solved.
* Have the resolution and "solving" of a platform's environments be machine agnostic.
* Have the software packages defined in the environments exist on immutable public package indexes.

### Hardware accelerated environments

Software the involves hardware acceleration on computing resources like GPUs requires additional information to be provided for full computational reproducibility.
In addition to the computer platform, information about the hardware acceleration device, its supported drivers, and compatible hardware accelerated versions of the software in the environment (GPU enabled builds) are required.
Traditionally this has been very difficult to do, but multiple recent technological advancements (made possible by social agreements and collaborations) in the scientific open source world now provide solutions to these problems.

::: challenge

## What are possible challenges of reproducible hardware accelerated environments?

::: solution

## Possible answers

Here are some you might have thought of:

* Installing hardware acceleration drivers and libraries on the machine with the GPU
* Knowing what drivers are supported for the available GPUs
* Providing instructions to install the same drivers and libraries on multiple computing platforms
* Having the "deployment" machine's resources and environment where the analysis is done match the "development" machine's environment

What did you come up with?

:::
:::

::: challenge

## Does computational reproducibility mean that the exact same numeric results should be achieved every time?

::: solution

Not necessarily.

What are additional reasons you thought of?

:::
:::

## Computational reproducibility vs. scientific reuse

Aiming for computational reproducibility is the first step to making scientific research more beneficial to us.
For the purposes of a single analysis this should be the primary goal.
However, just because a software environment is fully reproducible does not mean that the research is automatically reusable.
Reuse allows for the tools and components of the scientific workflow to be composable tools that can interoperate together to
create a workflow.
The steps of the workflow might exist in radically different computational environments and require different software, or different versions of the same software tools.
Given these demands, reproducible computational software environments are a first step toward full reusable scientific workflows.

This lesson will focus on computational reproducibility of hardware accelerated scientific workflows (e.g. machine learning).
Scientifically reusable analysis workflows are a more extensive topic, but this lesson will link to references on the topic.

::: keypoints

- Use `.md` files for episodes when you want static content
- Use `.Rmd` files for episodes when you need to generate output
- Run `sandpaper::check_lesson()` to identify any issues with your lesson
- Run `sandpaper::build_lesson()` to preview your lesson locally

:::
