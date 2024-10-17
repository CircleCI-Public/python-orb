#!/bin/bash
# shellcheck disable=SC2034  # Unused variables left for readability
# shellcheck disable=SC1090
PARAM_VERSION="$(echo "${PARAM_VERSION}" | circleci env subst)"
IFS='.'
read -r MAJOR MINOR PATCH <<< "$PARAM_VERSION"

Install_Pyenv() {
  echo "export PATH=$HOME/.pyenv/bin:$PATH" >> "$BASH_ENV"
  echo "export PYENV_ROOT=$HOME/.pyenv" >> "$BASH_ENV"
  echo "export PYTHON_VERSION=$PARAM_VERSION" >> "$BASH_ENV"
  echo "export PIPENV_DEFAULT_PYTHON_VERSION=$PARAM_VERSION" >> "$BASH_ENV"
  . "${BASH_ENV}"
  curl https://pyenv.run | bash
}

Install_Python() {
  if ! command -v "pyenv" >/dev/null 2>&1; then
    Install_Pyenv
  else
    echo "Pyenv is already installed"
  fi
  pyenv install "$PARAM_VERSION"
  pyenv global "$PARAM_VERSION"
  echo "BASH_ENV_PYTHON_ALIASED=true" >> "$BASH_ENV"
}

if [ "$SYS_ENV_PLATFORM" = "linux_alpine" ]; then
  if [ "$ID" = 0 ]; then export SUDO=""; else export SUDO="sudo"; fi
else
  if [ "$EUID" = 0 ]; then export SUDO=""; else export SUDO="sudo"; fi
fi

if [ -z "$MAJOR" ] || [ -z "$MINOR" ]; then
  echo "The version provide: $PARAM_VERSION is not valid"
  exit 1
fi

if ! command -v "python$MAJOR.$MINOR" >/dev/null 2>&1; then
  Install_Python
else
  echo "Python$MAJOR.$MINOR is already installed"
  exit 0
fi
