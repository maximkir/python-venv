![CI status](https://github.com/maximkir/python-venv-template/workflows/CI/badge.svg?branch=master)

# Python Virtual Environment 

Whenever I start a new Python project, I find myself spending time on virtual environment setup.
To increase productivity, I created a Makefile that takes care of creating, updating, and invoking Python virtual environments.
It will allow you to reduce venv related routines to almost zero!

This repo contains my customizations and is heavily based on [sio](https://github.com/sio/Makefile.venv)'s project.

## Installation

### Recommended method

Copy [*Makefile.venv*](Makefile.venv) to your project directory and add
include statement to the bottom of your `Makefile`:

```make
include Makefile.venv
```

### Alternative method

Alternatively, you can add installation actions as the Makefile rule:

> **Note the checksum step!** Do not skip it, it would be as bad as [piping curl
> to shell](https://0x46.net/thoughts/2019/04/27/piping-curl-to-shell/)!

```make

SHASUM = sha256sum # Linux GNU

ifeq ($(OS), Darwin)
	SHASUM = shasum --algorithm 256
endif

include Makefile.venv
Makefile.venv:
	curl \
		-o Makefile.fetched \
		-L "https://raw.githubusercontent.com/maximkir/python-venv/v2020.12.20/Makefile.venv"
	echo "1c79f371eda3c40441efaf59ecb830bd8c6b6f31ae0cac3f772626dcc498ac06 *Makefile.fetched" \
		| $(SHASUM) --check - \
		&& mv Makefile.fetched Makefile.venv
```

> Notes:
>
> * *curl* and/or *sha256sum* may not be available by default depending on what
>   OS and configuration is used
> * To install *sha256sum* on macOS use `brew install coreutils`

## Usage

When writing your Makefile use `$(VENV)/python` to refer to the Python
interpreter within virtual environment and `$(VENV)/executablename` for any
other executable in venv.

## Targets

*Makefile.venv* provides the following targets. Some are meant to be executed
directly via `make $target`, some are meant to be dependencies for other
targets written by you.

##### setup

Use this target to setup [pyenv](https://github.com/pyenv/pyenv)

##### venv

Use this as a dependency for any target that requires virtual environment to
be created and configured.

*venv* is a .PHONY target and rules that depend on it will be executed every
time make is run. This behavior is sensible as default because most Python
projects use Makefiles for running development chores, not for artifact
building. In cases where that is not desirable use [order-only prerequisite]
syntax:

```make
artifacts.tar.gz: | venv
	...
```

[order-only prerequisite]: https://www.gnu.org/software/make/manual/html_node/Prerequisite-Types.html

##### python

Execute this target to launch interactive Python shell within virtual
environment.

##### bash, zsh

Execute these targets to launch interactive command line shell. `shell` target
launches the default shell Makefile executes its rules in (usually /bin/sh).
`bash` and `zsh` can be used to refer to the specific desired shell (if it's
installed).

##### show-venv

Execute this target to show versions of Python and pip, and the path to the
virtual environment. Use this for debugging purposes.

##### clean-venv

Execute this target to remove virtual environment. You can add this as a
dependency to the `clean` target in your main Makefile.

##### $(VENV)/executablename

Use this target as a dependency for tasks that need `executablename` to be
installed if `executablename` is not listed as project's dependency neither in
`requirements.txt` nor in `setup.py`. Only packages with names matching the
name of the corresponding executable are supported.

This can be a lightweight mechanism for development dependencies tracking.
E.g. for one-off tools that are not required in every developer's
environment, therefore are not included in formal dependency lists.

**Note:** Rules using such dependency MUST be defined below
`include` directive to make use of correct $(VENV) value.

Example (see `ipython` target for another example):

```Makefile
codestyle: $(VENV)/pyflakes  # `venv` dependency is assumed and may be omitted
	$(VENV)/pyflakes .
```

## Variables

*Makefile.venv* can be configured via following variables:

##### PY

Command name for system Python interpreter. It is used only initially to
create the virtual environment. *Default: python3*

##### REQUIREMENTS_TXT

Space separated list of paths to requirements.txt files.
Paths are resolved relative to current working directory.
*Default: requirements.txt*

##### WORKDIR

Parent directory for the virtual environment. *Default: current working
directory*

##### VENVDIR

Python virtual environment directory. *Default: $(WORKDIR)/.venv*

##### PIP_*

Variables named starting with `PIP_` are not processed by *Makefile.venv* in
any way and are passed to underlying pip calls as is. See [pip
documentation](https://pip.pypa.io/en/stable/user_guide/#environment-variables)
for more information.

Use these variables to customize pip invocation, for example to provide custom
package index url:

```
PIP_EXTRA_INDEX_URL="https://your.index/url"
```

## Samples

Makefile:

```make
.PHONY: test
test: venv
	$(VENV)/python -m unittest

include Makefile.venv
```

Command line:

```
$ make test

...Skipped: creating and updating virtual environment...

...
----------------------------------------------------------------------
Ran 3 tests in 0.000s

OK
```
```
$ make show-venv
Python 3.6.8 (default, Aug 22 2020, 13:49:27) [GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.46.4)]
pip 20.2.4 from /Users/mkirilov/workspace/python-venv-template/.venv/lib/python3.6/site-packages/pip (python 3.6)
venv: ./.venv

```
```
$ make python
exec ./.venv/bin/python
Python 3.6.8 (default, Aug 22 2020, 13:49:27) 
[GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.46.4)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> _
```

## Contribution

Any PRs are welcome.
