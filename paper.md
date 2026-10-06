---
title: 'Reproducible Machine Learning Workflows for Scientists: A short course in best practices'
tags:
  - reproducible science
  - pixi
  - cuda
  - machine learning
  - carpentry
authors:
  - name: Matthew Feickert
    orcid: 0000-0003-4124-7862
    affiliation: 1
affiliations:
 - name: University of Wisconsin-Madison
   index: 1
date: 14 November 2025
bibliography: paper.bib
---

# Summary

A critical component of research software sustainability is the reproducibility of the software and computing environments software is executed in.
Researchers need reproducible computing environments for research software applications that may be run across multiple computing platforms &mdash; e.g. scientific analyses, visualization tools, data transformation pipelines, and artificial intelligence (AI) and machine learning (ML) applications on hardware accelerator platforms (e.g. GPUs).
Modern open source multi-platform environment management tools, e.g. Pixi [@pixi; @fischer_pixi:2025], provide automatic multi-platform digest-level lock file support for all dependencies &mdash; down to the compiler level &mdash; of software on public package indexes while still providing a high level interface well suited for researchers.
Combined with the arrival of the full CUDA [@CUDA_paper] stack on conda-forge [@conda-forge_community], it is now possible to declaratively specify a full CUDA accelerated software environment.

This work contains educational resources on applying these aspects of software reproducibility to hardware accelerated machine learning workflows.
The resources are presented as a short course, or "lesson", in The Carpentries [@the_carpentries_org] format designed to be taught to scientific researchers over the course of a three-day workshop.
The open source materials are hosted on GitHub by The Carpentries Incubator GitHub organization [@feickert_2025_17537699].
The course website is publicly accessible at [carpentries-incubator.github.io/reproducible-ml-workflows/](https://carpentries-incubator.github.io/reproducible-ml-workflows/).

# Statement of Need

Education and training for the broader scientific software community around robust best practices and standards for reproducibility in scientific software is rare, and is practically non-existent for reproducible hardware accelerated software.
This educational material provides tested and validated best practices for creating digest-level reproducible CUDA accelerated software environments and provides actionable recommendations for adopting computational reproducibility tools.
Given the recent advances in enabling technologies, the methods and techniques to support the described best practices and workflows were first made possible in late 2023.
As a result, this material is one of the first open source resources available on the topic.

# Instructional Design

The course has been designed to be taught over a three-day workshop, with each day divided into a half-day of instruction from the course material, and then a second half-day focusing on applying the course content to real world research applications to participants' research projects through interactive work sessions with the instruction team.
Each "episode" of the workshop course contains interactive "challenge" questions that require participants to put into practice concepts and tools they have just learned, and synthesize information from previous episodes to accomplish tasks.
After each challenge question, the instructor team will discuss possible solutions with the participants and "live code" a demonstration of a solution.

# Learning Objectives

By the end of the first day of instruction, participants will be able to:

* Describe the terms "reproducibility" and "reuse" as they relate to research computing.
* Describe what is needed for a computational environment to be reproducible.
* Describe what Pixi is, as well as its main features and benefits to reproducible software environments.
* Describe the content and purpose of a lock file.
* Use Pixi's command line interface (CLI) API to create a reproducible software environment.
* Describe the structure and functionality of the Pixi manifest file.
* Create and use tasks defined using Pixi's task runner system.
* Create a multi-platform Pixi workspace.

By the end of the second day of instruction, participants will be able to:

* Describe the structure of a conda package in both its `.conda` archive format and its installed form on disk.
* Describe the purpose of a conda virtual package.
* Describe how Pixi `system-requirements` enable resolution of CUDA enabled conda packages.
* Create Pixi software environments that use CUDA enabled conda packages of machine learning libraries for CUDA compatible computing platforms.
* Use CUDA enabled Pixi software environments to train machine learning models on NVIDIA GPUs.

By the end of the third day of instruction, participants will be able to:

* Describe the use of Linux containers for deployment of software environments to remote machines.
* Write a templated Dockerfile that uses Pixi software environments.
* Write a templated Apptainer container image definition that uses Pixi software environments.
* Build a Docker container image that contains a CUDA accelerated Pixi software environment.
* Build an Apptainer container image that contains a CUDA accelerated Pixi software environment.
* Write a continuous integration and continuous delivery (CI/CD) configuration file to build and deploy container images to container registries.
* Describe the benefits to the research process of using fully reproducible hardware accelerated software environments.

If participants are working with access to a high-throughput computing (HTC) facility, they will additionally be able to:

* Write simple HTCondor execution scripts and submit description files that request Linux container and GPU resources.
* Submit distributed machine learning training workflows to HTCondor that run in Linux containers with CUDA accelerated Pixi software environments.

and if participants are working with access to a high-performance computing (HPC) facility, they will additionally be able to:

* Write simple Slurm execution scripts and batch scripts that request GPU resources.
* Submit distributed machine learning training workflows to Slurm that run in CUDA accelerated Pixi software environments.

# Content

The content of the course is aimed at a target audience of professional researchers who already have experience with scientific software development, including file system structures, such as the Filesystem Hierarchy Standard of Unix-like systems, version control software, such as Git, and programming languages, such as Python or C++, and a working understanding of the goals of machine learning.
Experience with Linux containers and CI/CD systems are strongly beneficial to participation in the course, and while not strictly required, should be considered as non-optional to gain the most benefit from participation in the course.
The focus of the course is on applications using CUDA enabled Python machine learning libraries, as well as deploying these software environments to production settings on HTC and HPC systems.
This course does not teach machine learning concepts, but will focus on the methodologies and tools to make existing machine learning workflows reproducible.

# Experience of Use

As of 2025, the Reproducible Machine Learning Workflows for Scientists course has been taught to over 70 participants &mdash; ranging from university students, to tenured faculty, to industry machine learning researchers from universities, national laboratories, professional organizations, and companies.
As the full course content covers multiple concepts and technologies, individual episodes have also been selected to be taught as standalone 4-hour tutorials on targeted topics.
Long-term follow-up surveys, querying participants on changes to their scientific workflows three months after participating in a workshop, have shown evidence that participants find Pixi as a technology easy to learn and beneficial enough for researchers that it has changed their normal scientific software workflow habits, becoming a common tool in their regular work.
Additional experience teaching the course in different workshop settings is needed to expand the scope of responses to form a more complete understanding of long-term impact on participants.

# How the project came to be

This course was motivated from experience and difficulty in creating CUDA accelerated software environments for machine learning research studies in experimental physics.
The challenge was to create environments that could resolve quickly enough to allow for rapid experimentation on local compute resources and then be deployed to remote resources, while also being robust to temporal drift of software versions and compute platform hardware-level system requirements.
This multi-year challenge was disrupted in September, 2023 [@feickert_odsl:2023] with first experiments in using Pixi and CUDA enabled PyTorch builds from conda-forge, which led to questions of distributed computing applications for real world research problems.
Further motivation came from conversations with Pixi developers Ruben Arts and Wolf Vollprecht at the 2024 SciPy conference in July, 2024.
The course content was able to be researched, created, and taught at multiple workshops through support from an Early-Career Fellowship from the US Research Software Sustainability Institute.

# Acknowledgments

This work was supported by the US Research Software Sustainability Institute (URSSI) via grant G-2022-19347 from the Sloan Foundation.
This work benefitted from resources and services provided by the University of Wisconsin&ndash;Madison [Center for High Throughput Computing](https://chtc.cs.wisc.edu/) [@CHTC], as well as services provided by the [OSG Consortium](https://osg-htc.org/) [@osg07; @osg09; @OSPool; @OSDF], which is supported by the National Science Foundation awards #2030508 and #2323298.

# References
