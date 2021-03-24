# This Makefile can be configured via following variables:
#   PY
#       Command name for system Python interpreter. It is used only initialy to
#       create the virtual environment
#       Default: python3
#   REQUIREMENTS_TXT
#       Space separated list of paths to requirements.txt files.
#       Paths are resolved relative to current working directory.
#       Default: requirements.txt
#   WORKDIR
#       Parent directory for the virtual environment.
#       Default: current working directory.
#   VENVDIR
#   	Python virtual environment directory.
#   	Default: $(WORKDIR)/.venv

OS = $(shell uname)


define brew_install
	if ! brew ls --versions "$(1)" >/dev/null; then \
	    HOMEBREW_NO_AUTO_UPDATE=1 brew install "$(1)"; \
	fi
endef


define brew_install_or_upgrade
	if brew ls --versions "$(1)" >/dev/null; then \
	    HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "$(1)"; \
	else \
	    HOMEBREW_NO_AUTO_UPDATE=1 brew install "$(1)"; \
	fi
endef


PYTHON_VERSION?=3.6.8
PIP_VERSION?=20.2.4
VENV_PROMT=$(basename "${PWD}")

PY?=python3
WORKDIR?=.
VENVDIR?=$(WORKDIR)/.venv
VENV=$(VENVDIR)/bin
PYTHON=${VENV}/python
REQUIREMENTS_TXT?=$(wildcard requirements.txt)  # Multiple paths are supported (space separated)
MARKER=.initialized-with-Makefile.venv


#
# Pyenv staff
#

ifeq ($(OS),Darwin)
	PYENV = \
	LDFLAGS="-L$$(brew --prefix openssl)/lib" \
	CPPFLAGS="-I$$(brew --prefix openssl)/include" \
	pyenv
else
	PYENV = pyenv
endif

ifeq ($(OS),Linux)
	export PYENV_ROOT=${HOME}/.pyenv
	export PATH:=${PYENV_ROOT}/bin:${PATH}
endif

prerequisites: $(OS)

Darwin:
	brew update
	$(call brew_install,openssl)
	$(call brew_install_or_upgrade,pyenv)

Linux:
	# Clone a git repo if it does not exist, or pull into it if it does exist
	git clone https://github.com/pyenv/pyenv.git ~/.pyenv 2> /dev/null || git -C ~/.pyenv pull


#
# Virtual environment
#

.PHONY: venv
venv: $(VENV)/$(MARKER)

.PHONY: show-venv
show-venv: venv
	@$(VENV)/python -c "import sys; print('Python ' + sys.version.replace('\n',''))"
	@$(VENV)/pip --version
	@echo venv: $(VENVDIR)

.PHONY: debug-venv
debug-venv:
	@$(MAKE) --version
	$(info PY="$(PY)")
	$(info REQUIREMENTS_TXT="$(REQUIREMENTS_TXT)")
	$(info VENVDIR="$(VENVDIR)")
	$(info VENVDEPENDS="$(VENVDEPENDS)")
	$(info WORKDIR="$(WORKDIR)")


.PHONY: clean-venv
clean-venv:
	-$(RM) -r "$(VENVDIR)"

#
# Dependencies
#

ifneq ($(strip $(REQUIREMENTS_TXT)),)
VENVDEPENDS+=$(REQUIREMENTS_TXT)
endif

ifneq ($(wildcard setup.py),)
VENVDEPENDS+=setup.py
endif
ifneq ($(wildcard setup.cfg),)
VENVDEPENDS+=setup.cfg
endif


.PHONY: setup
setup: prerequisites venv 


$(VENV):
	@echo "Creating virtual env, python version is: ${PYTHON_VERSION}"
	$(PYENV) install --skip-existing ${PYTHON_VERSION}

	@eval "$$(pyenv init -)"; \
	$(PYENV) local ${PYTHON_VERSION}; \
	$(PY) -m venv --prompt ${VENV_PROMT} ${VENVDIR}

	$(PYTHON) -m pip install pip==${PIP_VERSION}
	$(PYTHON) -m pip install --upgrade setuptools wheel


# TODO: Add support for file content changes
$(VENV)/$(MARKER): $(VENVDEPENDS) | $(VENV)
ifneq ($(strip $(REQUIREMENTS_TXT)),)
	$(VENV)/pip install $(foreach path,$(REQUIREMENTS_TXT),-r $(path))
endif
ifneq ($(wildcard setup.py),)
	$(VENV)/pip install -e .
endif
	touch $(VENV)/$(MARKER)


.PHONY: clean
clean: clean-venv
	@rm -f .python-version
	@rm -Rf *.egg .cache .coverage .tox build dist docs/build htmlcov
	@find . -depth -type d -name __pycache__ -exec rm -Rf {} \;
	@find . -type f -name '*.pyc' -delete

#
# Interactive shells
#

.PHONY: python
python: venv
	exec $(VENV)/python

.PHONY: bash zsh
bash zsh: venv
	. $(VENV)/activate && exec $@
