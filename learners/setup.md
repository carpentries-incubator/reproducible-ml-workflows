---
title: Setup
---

## Data Sets

All data used in this lesson will either be downloaded from a long term archive as part of the lesson, or will be provided by the learners.

## GitHub Repository Setup

At the end of this lesson you will have created a personal GitHub repository that contains the information that you've learned.
This gives you version controlled examples that you can take forward with you as references for your own projects.

1. Create a [GitHub account](https://github.com/) if you don't have one yet.
1. Navigate to your GitHub profile (https://github.com/<username>) and click the "+" icon in the upper right hand side to [create a new repository](https://github.com/new).
1. Name the new repository named `pixi-lesson`, make it public, and give it a README and an [open source license](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository) (e.g. MIT License).
1. As GitHub requires two-factor authentication, it is highly recommended that you [generate an SSH key pair](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) specifically for GitHub, [add the generated SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account), and then use your SSH keys to connect with GitHub.

::: caution

# What do I do if I don't have Git installed on my machine?

Jump to the next section ("Software Setup") and install Pixi.
Then, run this command (which we'll cover in the lesson) in your terminal

```bash
pixi global install git
```

and you'll have Git installed. :+1:

You can of course install Git in other ways depending on your operating system, but this is straightforward and will work for everyone.

:::

## Software Setup

This lesson will focus on using technology that allows for fully reproducible multi-platform software environments.
[Pixi](https://pixi.sh/latest/), the technology that enables this, is the only tool that needs to be installed in advance of the lesson.

To install Pixi, follow the one-line [installation instructions on the documentation website](https://pixi.sh/latest/#installation) and then [install the shell autocompletions](https://pixi.sh/latest/advanced/installation/#autocompletion) for your respective terminal shell.
See the options below for Linux, macOS, and Windows to get the operating system level commands that are provided in the installation docs.

If you already have Pixi installed, update it to the latest version with

```shell
pixi self-update
```

::: discussion
Note that this lesson focuses specifically on the use of hardware acceleration libraries and machine learning libraries that use NVIDIA's CUDA, which is closed source and proprietary.
macOS users and Windows and Linux users that don't have access to NVIDIA GPUs can still follow this lesson, but may run into situations where they are not able to execute examples that use the hardware accelerated versions of machine learning libraries.
:::

::: spoiler

### Unix machines (Linux and macOS)

```bash
curl -fsSL https://pixi.sh/install.sh | sh
```

or

```bash
wget -qO- https://pixi.sh/install.sh | sh
```

#### Autocompletions

##### Bash

Add the following to the end of `~/.bashrc`:

```bash
eval "$(pixi completion --shell bash)"
```

##### Zsh

Add the following to the end of `~/.zshrc`:

```zsh
autoload -Uz compinit && compinit  # redundant with Oh My Zsh
eval "$(pixi completion --shell zsh)"
```

##### Fish

Add the following to the end of `~/.config/fish/config.fish`:

```fish
pixi completion --shell fish | source
```

:::

::: spoiler

### Windows

```powershell
powershell -ExecutionPolicy ByPass -c "irm -useb https://pixi.sh/install.ps1 | iex"
```

#### Autocompletions

##### Bash (available through Windows Terminal)

Add the following to the end of `~/.bashrc`:

```bash
eval "$(pixi completion --shell bash)"
```

##### PowerShell

Add the following to the end of `Microsoft.PowerShell_profile.ps1`.
You can check the location of this file by querying the `$PROFILE` variable in PowerShell.
Typically the path is `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`.

```powershell
(& pixi completion --shell powershell) | Out-String | Invoke-Expression
```

:::

## Docker (optional)

While not explicitly required for this lesson, if you would like to have a more full interactive experience with the material it is suggested that you install the Linux container runtime and tool [Docker](https://www.docker.com/).
Install instructions for Docker can be found for your specific platform on [the Docker docs website](https://docs.docker.com/desktop/).

::: callout

If you're on Linux and would prefer to use [Apptainer](https://apptainer.org/) &mdash; if you don't know what that is don't worry &mdash; you can install that with

```bash
pixi global install apptainer
```

:::

## OSPool (optional)

For components of this lesson that involve High-Throughput Computing we'll use the [Open Science Pool (OSPool)](https://osg-htc.org/services/ospool/), as it is accessible to any researcher affiliated with an established project at a United States-based academic, government, or non-profit institution (via an OSG-Operated Access Point).

(The 2025 version of this lesson is being taught in-person in the United States and so this is meant to ease infrastructure requirements, not to discriminate against people outside of the U.S. academic system.)

### [Request an OSPool account](https://portal.osg-htc.org/documentation/overview/account_setup/registration-and-login/#apply-for-ospool-access)

The first step is to [request an OSPool account through the Open Science Grid (OSG) Portal](https://portal.osg-htc.org/application).
All applications are reviewed by a Research Computing Facilitator, so only request an account if you plan to use it for research purposes beyond this lesson.

### Register for an Access Point

Once you have an OSPool account **and** have been contacted by a Research Computing Facilitator, [submit a request for an OSPool access point](https://portal.osg-htc.org/documentation/overview/account_setup/registration-and-login/#register-for-an-access-point).
Follow the instructions you are given and then verify your account by connecting to the access point and **also** add an SSH key pair for authentication.

### Verify your project

OSPool uses projects to track compute resources across users.
To see a list of all projects associated with your user account run

```bash
grep $USER /etc/condor/UserToProjectMap.txt
```

To set a project to associate job resource use with, add the following to your job submission files:

```
+ProjectName="<a project name from your list>"
```

### Verify that you can submit jobs to the OSPool using HTCondor

Follow the [OSPool documentation example](https://portal.osg-htc.org/documentation/htc_workloads/workload_planning/htcondor_job_submission/#overview-submit-jobs-to-the-ospool-using-htcondor).
