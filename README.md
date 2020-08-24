![CI status](https://github.com/maximkir/python-venv-template/workflows/CI/badge.svg?branch=master)

# Python Project Template

Whenever I start a new Python project, I find myself spending time on virtual environment setup.
To increase productivity, I created a template used to create a Python project in a virtual environment.

## Virtual Environments

A cooperatively isolated runtime environment that allows Python users and applications to install and upgrade Python distribution packages without interfering with the behaviour of other Python applications running on the same system.

See the [virtual environment] documentation for information on how this works.

## Usage

Use this repository as a template for your project.

Supported make targets:

- `setup` - Setup a development environment and install dependencies from `requirements.txt` file
- `pyenv` -  Sets up pyenv and a virtualenv for a project under the `.venv` directory
- `dependencies` - Installs/updates dependencies for the project
- `test` - Install dependencies for the project tests (from `requirements-test.txt`)
- `clean` - Cleans up any generated files


## To Do

- Add support for development dependencies installation

## Contribution

Any PRs are welcome.

[virtual environment]: https://docs.python.org/3/tutorial/venv.html
