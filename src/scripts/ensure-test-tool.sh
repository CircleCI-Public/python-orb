# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"

case ${DETECT_PKG_MNGR:-${PARAM_PKG_MNGR}} in
    pip)
        REQUIREMENTS_PATH=${PARAM_REQUIREMENTS_PATH:-requirements.txt}
    ;;
    pip-dist)
        REQUIREMENTS_PATH="requirements.txt"
    ;;
    pipenv) # TODO: use PIPENV_PIPFILE
        REQUIREMENTS_PATH="Pipfile"
        PYTHON_ENV_TOOL="pipenv"
    ;;
    poetry)
        PYTHON_INSTALL_ARGS="--no-ansi"
        REQUIREMENTS_PATH="pyproject.toml"
        PYTHON_ENV_TOOL="poetry"
    ;;
    uv)
        REQUIREMENTS_PATH="uv.lock"
        PYTHON_ENV_TOOL="uv"
    ;;
esac

if [ -f ${REQUIREMENTS_PATH} ]; then
    echo "INFO: Detected dependency file: $REQUIREMENTS_PATH"
else
    echo "WARNING: No dependency file for ${DETECT_PKG_MNGR:-${PARAM_PKG_MNGR}} found. ${REQUIREMENTS_PATH} expected."
fi

# Automatically install test package. unittest is preinstalled and not required.
if [ "${PARAM_TEST_TOOL}" != "unittest" ]; then
    if ! "${PYTHON_ENV_TOOL:+$PYTHON_ENV_TOOL run}" pip --disable-pip-version-check list | awk 'NR > 2 && NF > 0 { print $1 }' | grep -q "^${PARAM_TEST_TOOL}$"; then
        if [ "${PARAM_FAIL_IF_MISSING_TOOL}" = true ]; then
            echo "ERROR: Test package ${PARAM_TEST_TOOL} was not found"
            exit 1
        fi

        # If the test package is not detected, install using PYTHON_INSTALL_TOOL
        echo "INFO: Test package ${PARAM_TEST_TOOL} was not found. Installing..."
        if [ "$PYTHON_ENV_TOOL" = "uv" ]; then
            eval "uv add ${PYTHON_INSTALL_ARGS} ${PARAM_TEST_TOOL}"
        else
            eval "${PYTHON_ENV_TOOL:-pip} install ${PYTHON_INSTALL_ARGS} ${PARAM_TEST_TOOL}"
        fi
    else
        echo "INFO: Detected test package: $DETECT_TEST_TOOL"
    fi
fi
