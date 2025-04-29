---
title: Setup
---

## Data Sets

All data used in this lesson will either be downloaded from a long term archive as part of the lesson, or will be provided by the learners.

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

:::::::::::::::: spoiler

### Unix machines (Linux and macOS)

```shell
curl -fsSL https://pixi.sh/install.sh | sh
```

or

```shell
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

```shell
pixi completion --shell fish | source
```

::::::::::::::::::::::::

:::::::::::::::: spoiler

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

::::::::::::::::::::::::
