#!/usr/bin/env python3
# Copyright (c) speechtechlabs
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
#
# This file was inspired from https://github.com/kennethreitz/setup.py
import os
import re
from pathlib import Path

from setuptools import find_packages, setup

NAME = "project_name"
DESCRIPTION = "Project Description"
URL = "https://gitlab.speechtechlabs.com/phd/python_template"
EMAIL = "muradbozik@speechtechlabs.com"
AUTHOR = "Murad Bozik"
REQUIRES_PYTHON = ">=3.10.0"
VERSION = "0.0.0"
HERE = Path(__file__).parent

def fetch_variables(folder, filename=".env"):
    """Fetches environment variables from file
    Using python-dotenv could be better, but we stick to default packages for handling this"""
    path = os.path.join(folder, filename)
    if not os.path.exists(path):
        return {}

    with open(path, encoding="utf-8") as f:
        content = f.readlines()
    variables = {}
    content = [x.strip() for x in content]
    for x in content:
        if x == "":
            continue
        key, value = x.split("=")
        variables[key.strip("\"' ")] = value.strip("\"' ")
    return variables

VARIABLES = fetch_variables(HERE, ".env")

def replace_environment_variables(text):
    """Replaces variables if matches with keys in VARIABLES dictionary"""
    def replace(match):
        return VARIABLES.get(match.group(1), match.group(0))
    return re.sub(r"\$\{(\w+)\}", replace, text)


def fetch_requirements(folder, filename="requirements.txt"):
    """Fetches requirements from provided file"""
    with open(os.path.join(folder, filename), encoding="utf-8") as f:
        content = f.readlines()
    content = [replace_environment_variables(x).strip() for x in content]
    return [x for x in content if x != ""]


# What packages are required for this module to be executed?
REQUIRED = fetch_requirements(HERE)

# What packages are optional?
EXTRAS = {
    # "dev": ["flake8", "mypy", "pdoc3", "optuna"] # As an example
}

try:
    with open(HERE / "README.md", encoding="utf-8") as f:
        long_description = "\n" + f.read()
except FileNotFoundError:
    long_description = DESCRIPTION

setup(
    name=NAME,
    version=VERSION,
    description=DESCRIPTION,
    long_description=long_description,
    long_description_content_type="text/markdown",
    author=AUTHOR,
    author_email=EMAIL,
    python_requires=REQUIRES_PYTHON,
    url=URL,
    packages=find_packages(exclude=["tests", "*.tests", "*.tests.*", "tests.*"]),
    # extras_require=EXTRAS, # uncomment when releasing package
    # install_requires=REQUIRED, # uncomment when releasing package
    include_package_data=True,
    classifiers=[
        # Trove classifiers
        # Full list: https://pypi.python.org/pypi?%3Aaction=list_classifiers
        "Development Status :: 1 - Planning",
        "Programming Language :: Python :: 3.10",
        "Topic :: Multimedia :: Sound/Audio",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
    ],
)
