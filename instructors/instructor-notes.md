---
title: 'Instructor Notes'
---

## Workshop format

The lesson is designed to be taught as a three-day workshop.
Each day has a morning instruction session that covers episodes of the lesson, followed by an afternoon work session in which participants apply what they learned to real applications.
Strongly encourage participants to bring a research project or idea of their own to the work sessions, and plan for the instruction team to be available to help participants individually during them.

Each episode contains challenges that ask participants to put the concepts and tools they have just learned into practice.
After each challenge, discuss possible solutions with the participants and live code a solution.

## Before teaching the lesson

The lesson covers many technologies in three days: Pixi, conda packages, CUDA, Linux containers, CI/CD with GitHub Actions, and HTC and HPC systems.
To get through all of them, participants need a solid understanding of software development before the workshop, including the Unix shell, Git and GitHub, and programming in Python or a similar language (see the [prerequisites](../index.md)).
Make these expectations clear when advertising the workshop, and consider pointing participants to The Carpentries lessons on [The Unix Shell](https://swcarpentry.github.io/shell-novice/), [Version Control with Git](https://swcarpentry.github.io/git-novice/), and [Programming with Python](https://swcarpentry.github.io/python-novice-inflammation/) beforehand.

If you are teaching the lesson for the first time, teaching a subset of the episodes, such as a single day of the schedule below, is more reasonable than the full three-day workshop.

## Schedule

The schedule below follows the [Reproducible Machine Learning Workflows for Scientists Workshop 2025](https://indico.global/event/14982/), where each day's instruction session (09:00 to 12:30, including a 20-minute break) was run as a half-day tutorial.
The time estimates are the sum of the teaching and exercise times of the episodes, and do not include breaks or time to help participants who fall behind.
The workshop scheduled more time for each day than these estimates, and you should too.

| Day | Episodes | Episode time estimate |
|-----|----------|-----------------------|
| 1 | [Reproducible research](../episodes/introduction.md), [Introduction to Pixi](../episodes/pixi-intro.md), [Backwards compatibility with conda](../episodes/backwards-compatibility.md), [Conda packages](../episodes/conda-packages.md) | 2 hours 3 minutes |
| 2 | [CUDA conda packages](../episodes/cuda-conda-packages.md), [Deploying Pixi environments with Linux containers](../episodes/pixi-deployment.md) | 1 hour 30 minutes |
| 3 | [Using Pixi environments on HTC systems](../episodes/htc-systems.md), [Using Pixi environments on HPC systems](../episodes/hpc-systems.md) | 2 hours 10 minutes |

The HPC episode was added to the lesson after the August 2025 workshop, which used the second part of the third day's instruction session for material on commercial cloud systems that is not part of the lesson.

## Preparation

Ask participants to complete the [Setup](../learners/setup.md) instructions before the workshop, and offer time before the first instruction session to help those who could not.
Participants who have trouble with their setup early in the workshop can fall behind for the rest of it.

Each part of the lesson needs different resources, which can take time to arrange:

* **All episodes:** A laptop with a terminal emulator, a text editor, some free disk space, and Pixi installed. Windows users are strongly encouraged to use WSL 2 and Windows Terminal.
* **[CUDA conda packages](../episodes/cuda-conda-packages.md):** An NVIDIA GPU is needed to run the CUDA examples. Participants without one can still create and lock the CUDA environments, but can not run the examples on them.
* **[Deploying Pixi environments with Linux containers](../episodes/pixi-deployment.md):** A personal GitHub account, as the episode builds Linux container images with GitHub Actions and publishes them to the GitHub Container Registry. Docker or Apptainer is optional.
* **[Using Pixi environments on HTC systems](../episodes/htc-systems.md):** The same GitHub account, and an account on an HTC system with GPUs. The lesson uses the [OSPool](https://osg-htc.org/services/ospool/), where account requests are reviewed by a Research Computing Facilitator, so ask participants to apply well before the workshop.
* **[Using Pixi environments on HPC systems](../episodes/hpc-systems.md):** An account and allocation on an HPC system with GPUs that uses Slurm.

Access to GPUs at academic institutions often requires several steps and permissions, and few participants are likely to already have projects that use GPUs.
Arranging access to GPUs for the participants before the workshop, for example through the OSPool or your institution's research computing center, lets every participant run the GPU examples.

## Adapting the lesson

The lesson can be split into three parts that can be taught on their own, and that correspond to the days of the schedule above: Pixi and conda packages, deploying environments with Linux containers, and running machine learning workflows on HTC and HPC systems.
Later parts depend on the earlier ones: the container deployment episode builds on the CUDA environments and code from the CUDA conda packages episode, the HTC episode builds container images for CUDA environments with the GitHub Actions workflows introduced in the container deployment episode, and the HPC episode runs CUDA environments with Slurm.
If you teach a later part on its own, make sure participants already know the material it depends on.

The HTC and HPC episodes are specific to the OSPool and to Slurm, and are the episodes most likely to need changes for your own computing systems.

To teach a modified version of the lesson, fork the [lesson repository](https://github.com/carpentries-incubator/reproducible-ml-workflows) and follow the [Teaching section of The Carpentries Workbench FAQ](https://carpentries.github.io/workbench/faq.html#teaching) to deploy your fork's lesson website.
