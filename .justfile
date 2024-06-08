# Environment Management Justfile


# Define environment variables
MODULE_NAME := "project_name"
CONDA_EXE := env_var_or_default('CONDA_EXE', '~/miniconda3/bin/conda')
DEBUG_FILE := "debug.txt"
TESTS_NO_CI := file_stem(invocation_directory()) / "tests/no_ci"
PROJECT_DIR := file_stem(invocation_directory())
PROJECT_NAME := `grep -A 1 '\[project\]' pyproject.toml | awk -F' = ' '/name/ { gsub(/"/, "", $2); print $2; exit }'`
ARCH := `python3 -c "import platform; print(platform.platform())"`
LOCKFILE := "environment." + ARCH + ".lock.yaml"


@_default:
  echo "Project Variables:"
  echo "    PROJECT_NAME = {{PROJECT_NAME}}"
  echo "    DEBUG_FILE   = {{DEBUG_FILE}}"
  echo "    ARCH         = {{ARCH}}\n"
  just --list

# Create or update the conda environment and export the lockfile
create_environment: _update_and_export
  #!/usr/bin/env bash
  echo "New conda env created. Activate with:"
  echo ">>> conda activate {{PROJECT_NAME}}"
  echo ">>> just update_environment"
  if [[ -f .post-create-environment.txt ]]; then
    cat .post-create-environment.txt
  fi

# Delete the conda environment
delete_environment: _environment_deactivated
  #!/usr/bin/env bash
  if command -v {{CONDA_EXE}} > /dev/null 2>&1; then
    echo "Deleting conda environment."
    {{CONDA_EXE}} env remove -n {{PROJECT_NAME}} -y
    rm -f {{LOCKFILE}}
    just clean

    if [[ -f .post-delete-environment.txt ]]; then
      cat .post-delete-environment.txt
    fi
    echo "Completed!"
  else
    echo "Conda is not available. Please install conda!" >&2
    exit 1
  fi

# Install or update Python dependencies in the conda environment
update_environment: _environment_enabled _update_and_export
  #!/usr/bin/env bash
  echo "Conda env updated!"
  if [[ -f .post-create-environment.txt ]]; then
    cat .post-update-environment.txt
  fi

_update_and_export:
  #!/usr/bin/env bash
  if command -v {{CONDA_EXE}} > /dev/null 2>&1; then
    {{CONDA_EXE}} env update -n {{PROJECT_NAME}} -f environment.yaml
    {{CONDA_EXE}} env export -n {{PROJECT_NAME}} -f {{LOCKFILE}}
  else
    echo "Conda is not available. Please install conda!" >&2
    exit 1
  fi

# Check that the conda environment is active
_environment_enabled:
  #!/usr/bin/env bash
  if command -v {{CONDA_EXE}} > /dev/null 2>&1; then
    if [[ $(basename $CONDA_DEFAULT_ENV) != {{PROJECT_NAME}} ]]; then
      echo "Run 'conda activate {{PROJECT_NAME}}' before proceeding..." >&2
      exit 1
    fi
  else
    echo "Conda is not available. Please install conda!" >&2
    exit 1
  fi

# Check that the conda environment is deactivated
_environment_deactivated:
  #!/usr/bin/env bash
  if command -v {{CONDA_EXE}} > /dev/null 2>&1; then
    if [[ $(basename $CONDA_DEFAULT_ENV) == {{PROJECT_NAME}} ]]; then
      echo "Run 'conda deactivate' before proceeding..." >&2
      exit 1
    fi
  else
    echo "Conda is not available. Please install conda!" >&2
    exit 1
  fi

# Test that an environment lockfile exists
_check_lockfile:
  #!/usr/bin/env bash
  if [[ ! -f {{LOCKFILE}} ]]; then
    echo "Run 'just update_environment' before proceeding..." >&2
    exit 1
  fi

# Check if environment is enabled and correctly configured
@check_environment:
  just _environment_enabled
  just _check_lockfile
  echo "Environment correctly configured!"

# Dump useful debugging information to $(DEBUG_FILE)
debug_environment: _environment_enabled
  @echo "\n\n======================"
  @echo "\nPlease include the contents {{DEBUG_FILE}} when submitting an issue or support request.\n"
  @echo "======================\n\n"
  @echo "##\n## Git status\n##\n" > {{DEBUG_FILE}}
  git status >> {{DEBUG_FILE}}
  @echo "\n##\n## git log\n##\n" >> {{DEBUG_FILE}}
  git log -8 --graph --oneline --decorate --all >> {{DEBUG_FILE}}
  @echo "\n##\n## Github remotes\n##\n" >> {{DEBUG_FILE}}
  git remote -v >> {{DEBUG_FILE}}
  @echo "\n##\n## github SSH credentials\n##\n" >> {{DEBUG_FILE}}
  ssh git@github.com 2>&1 | cat >> {{DEBUG_FILE}}
  @echo "\n##\n## Conda config\n##\n" >> {{DEBUG_FILE}}
  {{CONDA_EXE}} config --get >> {{DEBUG_FILE}}
  @echo "\n##\n## Conda info\n##\n" >> {{DEBUG_FILE}}
  {{CONDA_EXE}} info  >> {{DEBUG_FILE}}
  @echo "\n##\n## Conda list\n##\n" >> {{DEBUG_FILE}}
  {{CONDA_EXE}} list >> {{DEBUG_FILE}}


# Clean up compiled Python files, cache directories, and build artifacts
clean:
    @echo "Deleting .pyc and .pyo files..."
    @find . -type f -name "*.py[co]" -delete

    @echo "Deleting __pycache__ directories..."
    @find . -type d -name "__pycache__" -delete

    @echo "Deleting .make.* files..."
    @rm -f .make.*

    @echo "Deleting .egg-info directories..."
    @find . -type d -name "*.egg-info" -exec rm -rf {} +

    @echo "Clean up completed!"
