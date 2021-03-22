import os
import platform

EXPECTED_VERSION = os.getenv("PYTHON_VERSION")


def test_version():
    assert platform.python_version() == EXPECTED_VERSION
