---
title: "Introduction to Pixi"
teaching: 10
exercises: 8
---

::: questions

* What is Pixi?
* How does Pixi enable fully reproducible software environments?
* What are Pixi's semantics?

:::

::: objectives

* Learn Pixi's workflow design
* Understand the relationship between a Pixi manifest and a lock file
* Understand how to create a multi-platform and multi-environment Pixi workspace

:::

## Pixi

As described in the previous section on computational reproducibility, to have reproducible software environments we need tools that can take high level human writeable environment configuration files and produce machine readable hash level lock files that exactly specify every piece of software that exists in an environment.

[Pixi](https://www.pixi.sh/) a cross-platform package and environment manager that can handle complex development workflows.
Importantly, Pixi automatically and non-optionally will produce or update a lock file for the software environments defined by the user whenever any actions mutate the environment.
Pixi is written in Rust, and leverages the language's speed and technologies to solve environments fast.

::: keypoints

* Pixi

:::
