#!/bin/bash
PARAM_VERSION="$(echo "${PARAM_VERSION}" | circleci env subst)"
IFS='.' 
read -r MAJOR MINOR PATCH <<< "$PARAM_VERSION"

Install_Python() {
  wget "https://www.python.org/ftp/python/$PARAM_VERSION/Python-$PARAM_VERSION.tgz"
  tar -xf Python-$PARAM_VERSION.tgz
  rm -f Python-$PARAM_VERSION.tgz
  cd Python-$PARAM_VERSION
  ./configure --enable-optimizations
  make
  $SUDO make altinstall
  
  ln -s "/usr/local/bin/python$MAJOR.$MINOR" "/usr/bin/python$MAJOR.$MINOR"
  "python$MAJOR.$MINOR" -m ensurepip --upgrade
  "python$MAJOR.$MINOR" -m pip install --upgrade pip
  ln -s "/usr/local/bin/pip$MAJOR.$MINOR" "/usr/bin/pip$MAJOR.$MINOR"

  shopt -s expand_aliases
  alias python="python$MAJOR.$MINOR"
  alias pip="pip$MAJOR.$MINOR"
  echo "export BASH_ENV_PYTHON_ALIASED=true" >> "$BASH_ENV"
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

# The release is only found with the format x.x.x, if the format is x.x detect the latest version for x.x
if [ -z "$PATCH" ]; then
  PATCHES=$(curl https://www.python.org/ftp/python/ | grep -Po "(?<=href=\")$PARAM_VERSION\.[0-9]+(?=/\")")
  LATEST_PATCH=$(echo "$PATCHES" | sort -V | tail -n 1)
  PARAM_VERSION="$LATEST_PATCH"
  read -r MAJOR MINOR PATCH <<< "$PARAM_VERSION"
fi

if ! command -v "python$MAJOR.$MINOR" >/dev/null 2>&1; then
  Install_Python
else
  echo "Python$MAJOR.$MINOR is already installed"
  exit 0
fi
