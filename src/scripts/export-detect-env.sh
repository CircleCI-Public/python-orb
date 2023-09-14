# shellcheck disable=SC2016
echo 'if [ "${PARAM_PKG_MNGR}" = "auto" ]; then
  if [ -f "requirements.txt" ]; then
      if [ -f "${PARAM_SETUP_FILE_PATH:-setup.py}" ]; then
          export DETECT_PKG_MNGR="pip-dist"
      else
          export DETECT_PKG_MNGR="pip"
      fi
  elif [ -f "Pipfile" ]; then
      export DETECT_PKG_MNGR="pipenv"
      export PYTHON_ENV_TOOL="pipenv"
  elif [ -f "pyproject.toml" ]; then
      if grep -q "setuptools" pyproject.toml; then
            export DETECT_PKG_MNGR="pip-dist"
      else
            export DETECT_PKG_MNGR="poetry"
            export PYTHON_ENV_TOOL="poetry"
      fi 
  echo "INFO: Detected Package Manager ${DETECT_PKG_MNGR}"
fi' > /tmp/detect-env.sh
chmod +x /tmp/detect-env.sh
echo 'export AUTO_DETECT_ENV_SCRIPT="/tmp/detect-env.sh"' >> "$BASH_ENV"