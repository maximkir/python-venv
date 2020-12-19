SHELL:=/bin/bash
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


.PHONY: help dependencies pyenv setup clean

PYTHON_VERSION?=3.6.8
VENV_PROMT=$(basename "${PWD}")
VENV_DIR?=.venv
PYTHON=${VENV_DIR}/bin/python
VENV_ACTIVATE=. $(VENV_DIR)/bin/activate


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

.DEFAULT: help

help:
	@echo "Please choose one of the following targets:"
	@echo
	@echo "    prerequisites: Installs prerequisites software"
	@echo "    pyenv: Sets up pyenv and a virtualenv for this project"
	@echo "    dependencies: Installs dependencies for this project"
	@echo "    setup: Setup your development environment and install dependencies"
	@echo "    test: Install test dependencies"
	@echo "    clean: Cleans any generated files"
	@echo


pyenv:
	@echo "Creating virtual env, python version is: ${PYTHON_VERSION}"

	$(PYENV) install --skip-existing ${PYTHON_VERSION}

	@eval "$$(pyenv init -)"; \
	pyenv local ${PYTHON_VERSION}; \
	python3 -m venv --prompt ${VENV_PROMT} ${VENV_DIR}

	$(PYTHON) -m pip install --upgrade pip

dependencies:
	$(PYTHON) -m pip install -r requirements.txt


setup: prerequisites pyenv dependencies

test:
	@test ! -f "requirements-test.txt" || ($(PYTHON) -m pip install -r requirements-test.txt)

clean:
	@rm -rf ${VENV_DIR}
	@rm -f .python-version
	@rm -Rf *.egg .cache .coverage .tox build dist docs/build htmlcov
	@find . -depth -type d -name __pycache__ -exec rm -Rf {} \;
	@find . -type f -name '*.pyc' -delete
