if [ ! "${BASH_ENV_PYTHON_ALIASED}" ]; then
    echo 'if [ ! $(command -v python) ]; then
  shopt -s expand_aliases
  alias python=python3
  alias pip=pip3
fi

BASH_ENV_PYTHON_ALIASED=true' >> "$BASH_ENV"
fi