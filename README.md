# Reproducible Machine Learning Workflows for Scientists

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17537698.svg)](https://doi.org/10.5281/zenodo.17537698)

This repository contains a Carpentries format lesson covering technologies and best practices for reproducible machine learning workflows.
The lesson has been designed to be taught over a three-day workshop, with each day divided into a half-day of instruction from the lesson material, and then a second half-day focusing on applying the lesson content to real world research applications to participants' research projects through interactive work sessions with the instruction team.

The content of the lesson is aimed at a target audience of professional researchers who already have experience with scientific software development, including file system structures, such as the Filesystem Hierarchy Standard of Unix-like systems, version control software, such as Git, and programming languages, such as Python or C++, and a working understanding of the goals of machine learning.

## Using the lesson

To step through the lesson, please follow it on its website at https://carpentries-incubator.github.io/reproducible-ml-workflows/

## Getting help

* If you have questions about the lesson content or if something seems unclear, please open a [GitHub Discussion](https://github.com/carpentries-incubator/reproducible-ml-workflows/discussions).
GitHub Discussions that can not be resolved will be converted into GitHub Issues to be followed up on.
* If you have failed to reproduce results in the lesson content, or have found a bug, or something conceptually wrong, please open a [GitHub Issue](https://github.com/carpentries-incubator/reproducible-ml-workflows/issues).

## Contributing

Contributions to the lesson are welcome.
Before starting any work on a contribution idea, please first review the [Code of Conduct](https://github.com/carpentries-incubator/reproducible-ml-workflows/blob/main/CODE_OF_CONDUCT.md) and the [`CONTRIBUTING.md`](https://github.com/carpentries-incubator/reproducible-ml-workflows/blob/main/CONTRIBUTING.md).

## Developing the lesson

Similar to the lesson itself, development of the lesson uses [Pixi](https://pixi.sh/) to have unified multi-platform reproducible environments.
To start developing:

1. [Install Pixi](https://pixi.sh/)
2. [Fork this repository on GitHub](https://github.com/carpentries-incubator/reproducible-ml-workflows/fork)
3. Clone your fork and navigate to the top level of the repository
4. Run

```
pixi run start
```

and then open up the served site in your local browser and carry on with development.

> [!TIP]
> This lesson uses [The Carpentries Workbench][workbench].
> Consider reviewing The Workbench documentation and [infrastructure][] before starting development.

[workbench]: https://carpentries.github.io/sandpaper-docs/
[infrastructure]: https://carpentries.github.io/workbench/
