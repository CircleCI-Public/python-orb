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
esac

if [ -f ${REQUIREMENTS_PATH} ]; then
    echo "INFO: Detected dependency file: $REQUIREMENTS_PATH"
else
    echo "WARNING: No dependency file for ${DETECT_PKG_MNGR:-${PARAM_PKG_MNGR}} found. ${REQUIREMENTS_PATH} expected."
fi

# Automatically install test package. unittest is preinstalled and not required.
if [ "${PARAM_TEST_TOOL}" != "unittest" ]; then
    DETECT_TEST_TOOL=$(eval "${PYTHON_ENV_TOOL:+$PYTHON_ENV_TOOL run} pip --disable-pip-version-check list" |
    awk 'NR > 2 && NF > 0 { print $1 }' | grep "^${PARAM_TEST_TOOL}$") 2> error.txt
    
    NOT_DETECTED=$?
    
    if (( NOT_DETECTED > 0 )) && [ "${PARAM_FAIL_IF_MISSING_TOOL}" = true ]; then
        exit $NOT_DETECTED
    fi
    
    # If the test package is not detected, install using PYTHON_INSTALL_TOOL
    if [ -z "$DETECT_TEST_TOOL" ]; then
        echo "INFO: Test package ${PARAM_TEST_TOOL} was not found. Installing..."
        eval "${PYTHON_ENV_TOOL:-pip} install ${PYTHON_INSTALL_ARGS} ${PARAM_TEST_TOOL}"
        INSTALL_RESULT=$?
    else
        echo "INFO: Detected test package: $DETECT_TEST_TOOL"
    fi
    
    # Exit with test package install result, or exit 0 if param fail is set to false
    if (( NOT_DETECTED > 0 )) && [ "${PARAM_FAIL_IF_MISSING_TOOL}" = false ]; then
        exit ${INSTALL_RESULT:-0}
    fi
fi