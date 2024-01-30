# Dotfiles

This project was designed to save configuration files (usually dotfiles) to be
able to (re)install them later/elsewhere.

## Features

- Specify files to save in a register
- Save the files locally (make copies of these files)
- Install the files where they used to be

## Requirements

The shell scripts use bash syntaxes and [yq](https://github.com/mikefarah/yq).

## Installation

To install this app, clone this repository with

```git clone https://github.com/risisios/dotfiles```

and delete the Git files (under `.git`) with

```rm -drf .git```

## Usage

To use the app you need to first [create a register](#create-a-register), named `register.yaml` and
placed under `files`.

After that, you need to save the files with `make save`.

Finally clone your files elsewhere (e.g. on another computer, respecting the [requirements](#requirements)) and `make install`, to install them where they were originally.

## Create a register

The register file is structured wy the following rules:

- it stores a list of groups of files, each group is identified by the
  `directory` in which it will be stored (under `files`)
- each group of files must contain a list of files in the `files` entry
- files of the list of files may be specified by their `location` (i.e. the
  directory they are stored into), or a `location` in which files matching a
  `pattern` will be searched for

Here is an example of a register for saving the bash and tmux files:

```
- directory: bash
  files:
    - location: '~'
      pattern: '.bash*'
- directory: tmux
  files:
    - label: scripts
      location: '.tmux'
    - label: config
      location: '~/.config/tmux'
```

which will result in he following files structure:

```
files
   +- bash
   |    +- .bashrc
   |    +- ...
   +- tmux
   |    +- scripts
   |    |       +- ...
   |    +- config
   |           +- tmux.conf
   +- register.yaml
```

### Notes

#### Specifying patterns

Be careful with the patterns as it can duplicate files/directories, for
instance:
```
- directory: example
  files:
    - location: '~'
    pattern: '.example*'
    - label: 'sub'
    location: '~/.example'
- ...
```

will produce the following structure:
```
files
   +- example
   |       +- ...
   |       +- .example
   |       |        +- 1
   |       |        +- ...
   |       +- sub
   |           +- 1
   |           +- ...
   +- ...
   +- register.yaml
```
where `sub` is a duplicate of `.example`.

This is an issue, but is what is asked for in the register (not a bug).

#### Special characters in locations and patterns

If the `location` or the `pattern` contains special characters (such as `.`,
`$`, etc.) its value needs to be enclosed between quotes (see the YAML
specifications).
