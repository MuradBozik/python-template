# python_template

Template repo for python AI projects

Big thanks to Kjell Wooding kjell@wooding.org
Inspired by this repo: https://github.com/hackalog/make_better_defaults.git

**!IMPORTANT**
Don't forget to change following parts:

- project_name folder
- environment.yaml name
- project_name in pyproject.toml

# Environment Management

This repository uses justfile for managing the conda environment.
Make sure you to install `conda` and `just >= 1.27`. You can install `just` using `cargo install just`.

We rely on conda's dependency solver for handling both conda and pip packages. When a package installed directly using `pip install <package_name>` naturally pip dependency solver doesn't check conda packages. Thus, instead of installing pip packages directly we can add them into `environment.yaml` file and let conda solver handling package dependency check.

The only purpose of using the `just` is to automate simple commands. At the end of both `just create_environment` and `just update_environment` commands the prepared environment is exported to a lock.yaml file. The name of this file includes platform information such as OS, version, architecture etc. An example filename is `environment.Linux-5.15.102-0515102-generic-x86_64-with-glibc2.35.lock.yml`. By using this lock file every team member can use the same environment on the same machines consistently.

**NOTE:** If there are local packages in `environment.yaml` file, they will not be seen as local packages in created lock files.
For example:
```yaml
name: project_name
channels:
  - defaults
  - conda-forge
dependencies:
  - pip
  - setuptools
  - wheel
  - python=3.12
  - pip:
    - ./path/to/local_package.whl
```
This local_package will be seen as it is installed from pypi in lock file. The created lock file also needs to be updated to point to the local package file.


`environment.yaml` file is meant for development environment. Use `requirements.txt` for production packages. 

You can use `just` to see available recipes. An example output looks like this:
```
Project Variables:
    PROJECT_NAME = project_name
    DEBUG_FILE   = debug.txt
    ARCH         = macOS-10.16-x86_64-i386-64bit

Available recipes:
    check_environment  # Check if environment is enabled and correctly configured
    clean              # Clean up compiled Python files, cache directories, and build artifacts
    create_environment # Create or update the conda environment and export the lockfile
    debug_environment  # Dump useful debugging information to $(DEBUG_FILE)
    delete_environment # Delete the conda environment
    update_environment # Install or update Python dependencies in the conda environment
```


## Issues
If your conda environment stuck at resolving packages, make sure:
```
# Install conda-build in base environment
conda activate base
conda install conda-build

# Update both conda and conda-build
conda activate base
conda update conda
conda update conda-build

# In the new conda (after 22.11) the default solver is libmamba
# Make sure it is installed and default solver for fast environment creation and updates
conda install -n base conda-libmamba-solver
conda config --set solver libmamba
```
