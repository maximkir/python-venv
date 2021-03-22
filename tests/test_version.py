import os
import pip
import platform

EXPECTED_PYTHON_VERSION = os.getenv("PYTHON_VERSION")
EXPECTED_PIP_VERSION = os.getenv("PIP_VERSION")


def test_python_version():
    assert platform.python_version() == EXPECTED_PYTHON_VERSION


def test_pip_version():
    assert pip.__version__ == EXPECTED_PIP_VERSION
