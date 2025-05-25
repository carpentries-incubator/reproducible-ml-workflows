---
title: "Computational Reproducibility"
teaching: 10
exercises: 2
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


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

Inline instructor notes can help inform instructors of timing challenges
associated with the lessons. They appear in the "Instructor View"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::: challenge

## What are other challenges to reproducible research?

:::: solution

There are many! Here are some you might have thought of:

* (Not having) Access to data
* Unreproducible builds of software that isn't packaged and distributed on public package indexes
* Analysis code not being under version control
* Not having any environment definition configuration files

What did you come up with?

::::
::::

::: keypoints

- Use `.md` files for episodes when you want static content
- Use `.Rmd` files for episodes when you need to generate output
- Run `sandpaper::check_lesson()` to identify any issues with your lesson
- Run `sandpaper::build_lesson()` to preview your lesson locally

:::

[r-markdown]: https://rmarkdown.rstudio.com/
