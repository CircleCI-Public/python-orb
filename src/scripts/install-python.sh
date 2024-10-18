#!/bin/bash
# shellcheck disable=SC2034  # Unused variables left for readability
# shellcheck disable=SC1090
PARAM_VERSION="$(echo "${PARAM_VERSION}" | circleci env subst)"
IFS='.'
read -r MAJOR MINOR PATCH <<< "$PARAM_VERSION"

detect_os() { 
  detected_platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

  case "$detected_platform" in
    linux*)
        if grep "Alpine" /etc/issue >/dev/null 2>&1; then
            printf '%s\n' "Detected OS: Alpine Linux."
            SYS_ENV_PLATFORM=linux_alpine
        else
            printf '%s\n' "Detected OS: Linux."
            SYS_ENV_PLATFORM=linux
        fi  
      ;;
    darwin*)
      printf '%s\n' "Detected OS: macOS."
      SYS_ENV_PLATFORM=macos
      ;;
    msys*|cygwin*)
      printf '%s\n' "Detected OS: Windows."
      SYS_ENV_PLATFORM=windows
      ;;
    *)
      printf '%s\n' "Unsupported OS: \"$detected_platform\"."
      exit 1
      ;;
  esac

  export SYS_ENV_PLATFORM
}

Install_Pyenv() {
  {
    echo "export PYENV_ROOT=$HOME/.pyenv"
    echo "export PATH=$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH"
    echo "export PYTHON_VERSION=$PARAM_VERSION"
    echo "export PIPENV_DEFAULT_PYTHON_VERSION=$PARAM_VERSION"
  } >> "$BASH_ENV"
  . "$BASH_ENV"
  curl https://pyenv.run | bash
}
PATH=/root/.pyenv/shims:/root/.pyenv/bin:/root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Install_Python() {
  if ! command -v "pyenv" >/dev/null 2>&1; then
    Install_Pyenv
  else
    echo "Pyenv is already installed"
  fi
  "$PYENV_ROOT/bin/pyenv" install "$PARAM_VERSION"
  "$PYENV_ROOT/bin/pyenv" global "$PARAM_VERSION"
  echo "BASH_ENV_PYTHON_ALIASED=true" >> "$BASH_ENV"
}

if [ "$SYS_ENV_PLATFORM" = "linux_alpine" ]; then
  if [ "$ID" = 0 ]; then export SUDO=""; else export SUDO="sudo"; fi
else
  if [ "$EUID" = 0 ]; then export SUDO=""; else export SUDO="sudo"; fi
fi

if [ -z "$MAJOR" ] || [ -z "$MINOR" ]; then
  echo "The version provided: $PARAM_VERSION is not valid"
  exit 1
fi

if ! python --version | grep "Python $PARAM_VERSION" >/dev/null 2>&1; then
  Install_Python
else
  echo "Python$PARAM_VERSION is already installed"
  exit 0
fi
