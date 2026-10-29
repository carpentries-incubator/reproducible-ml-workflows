---
title: Learner Profiles
---

The profiles below describe fictional people who represent the intended audience of this lesson.
They show the background learners are expected to arrive with, the problems that bring them to the lesson, and what they want to be able to do after it.
They can help you decide whether the lesson fits the people you plan to teach, and which parts of it to emphasize.

## Priya the particle physics graduate student

Priya is a second year PhD student in experimental particle physics.
They learned Python as an undergraduate, use the Unix shell and Git every day, and attended a Software Carpentry workshop at the start of their PhD.

Priya trains a graph neural network with PyTorch to identify particle jets.
They develop the model on a Windows laptop with WSL 2 that has no NVIDIA GPU, and train it on a shared lab workstation with a GPU, where a senior student set up a conda environment years ago.
The research group shares environments as `environment.yml` files without pinned versions, and a labmate who recreated the environment last month got different package versions and could not reproduce Priya's training results.

The lab workstation is no longer enough for the hyperparameter scans that Priya needs to run, and their advisor has suggested using the OSPool.
Priya has never built a Linux container or used HTCondor.

From the lesson, Priya wants to learn how to:

* Define locked environments for both their laptop and the GPU workstation, and resolve the CUDA environment without having a GPU on their laptop.
* Keep sharing environments with labmates who still use conda.
* Build a container image of their environment and use it to run many training jobs on the OSPool.

## Tomás the climate science postdoc

Tomás is a postdoctoral researcher in climate science.
They are an experienced Python programmer who builds machine learning emulators of climate model components with JAX, and they have used their university's HPC cluster with Slurm for several years.

Tomás installs their software on the cluster on top of the CUDA modules that the cluster provides.
After the cluster's last system upgrade the old CUDA module was removed, and the environment that produced the results in their submitted paper no longer works.
A reviewer has asked for an additional experiment, and Tomás can not be sure that a rebuilt environment will give results consistent with the original ones.
They also develop on a macOS laptop and want the same versions of their packages there.

Tomás already knows how to write and submit Slurm batch scripts, and does not need the lesson to teach them HPC.
From the lesson, Tomás wants to learn how to:

* Get CUDA from conda packages instead of the system modules, so that their environment is not broken by changes to the cluster.
* Lock the exact versions of every package in the environment for both Linux and macOS, and keep the lock file with their code in Git so that the environment for each result can be recreated.
* Run their locked GPU environment on the cluster through Slurm.

## Sam the research computing facilitator

Sam is a research computing facilitator at a university research computing center, where they help researchers from many fields get their work running on the center's HTC and HPC systems.
They have a background in computational chemistry, are comfortable with Linux system administration, Docker, Apptainer, and GitHub Actions, and have taught Software Carpentry workshops.

A large part of Sam's support requests come from researchers whose GPU software environments work on their own machines but not on the center's systems, often because of mismatched CUDA versions.
Sam has used conda but has not used Pixi, and does not know how CUDA is distributed on conda-forge.

From the lesson, Sam wants to learn how to:

* Use Pixi and the CUDA packages on conda-forge to build GPU environments that researchers can reproduce on the center's systems.
* Automate building and publishing container images of these environments with GitHub Actions, so that researchers do not have to build images themselves.
* Teach this workflow to the researchers they support, adapting the HTC and HPC episodes to the center's own systems.

Sam is likely to be ahead of other learners on the container and CI/CD material, and can help the instruction team during the work sessions.

## Who this lesson is not designed for

The lesson covers many technologies in a short time, and it is not a good fit for:

* People who are new to the Unix shell, Git, or programming. The Software Carpentry lessons on [The Unix Shell](https://swcarpentry.github.io/shell-novice/), [Version Control with Git](https://swcarpentry.github.io/git-novice/), and [Programming with Python](https://swcarpentry.github.io/python-novice-inflammation/) are a better place to start.
* People who want to learn machine learning concepts or how to build and train models. The lesson uses existing machine learning examples, and does not explain how they work.
