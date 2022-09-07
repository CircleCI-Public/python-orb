if [ ! "${BASH_ENV_PYTHON_ALIASED}" ]; then
    echo 'if [ ! $(command -v python) ]; then
  EXPAND_ALIASES=$(shopt expand_aliases | cut -d " " -f 2 | xargs)

  shopt -s expand_aliases
  alias python=python3
  alias pip=pip3

  if [ "${EXPAND_ALIASES}" == "off" ]; then
    shopt -u expand_aliases
  fi
fi

BASH_ENV_PYTHON_ALIASED=true' >> "$BASH_ENV"
fi