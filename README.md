# python_template

Template repo for python AI projects

Big thanks to Kjell Wooding kjell@wooding.org
Original repo link: https://github.com/hackalog/make_better_defaults.git

**!IMPORTANT**
Don't forget to change following parts:

- project_name folder
- environment.yml name
- NAME and URL parameters in setup.py

# Environment Management

For managing environment use `make` command. Because it provides better conflict management over dependencies. Also, I strongly discourage to install a package directly using  `pip install <package_name>`. Instead, add required package to `environment.yml` file and use `make update_environment` command. Reserve requirements.txt for production packages. This will check dependencies and create a new lock file based on machine variables. Output filename looks like `environment.Linux-5.15.102-0515102-generic-x86_64-with-glibc2.35.lock.yml`. By using this lock file every team member can use the same environment on the same machines consistently.

You can use `make show-help` to see available commands this will output:
```
To get started:
  >>> make create_environment
  >>> conda activate audio_processor
  >>> make update_environment

Project Variables:

PROJECT_NAME = audio_processor
DEBUG_FILE = debug.txt
ARCH = Linux-5.4.0-150-generic-x86_64-with-glibc2.27

Available rules:
check_environment   Check if environment is enabled and correctly configured
clean               Delete all compiled Python files
create_environment  Set up virtual (conda) environment for this project
debug_environment   dump useful debugging information to $(DEBUG_FILE)
delete_environment  Delete the virtual (conda) environment for this project
update_environment  Install or update Python Dependencies in the virtual (conda) environment
```

Using `make` command also creates automatic documentation. This can be explored further to improve the usability and explainablity of the repository.


## Issues
If your conda environment stucks at resolving packages, make sure:
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
