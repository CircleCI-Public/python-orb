case ${DETECT_PKG_MNGR:-PARAM_PKG_MNGR} in
    pip)
        REQUIREMENTS_PATH=${PARAM_REQUIREMENTS_PATH:-requirements.txt}
    ;;
    pip-dist)
        REQUIREMENTS_PATH="requirements.txt"
    ;;
    pipenv) # TODO: use PIPENV_PIPFILE
        REQUIREMENTS_PATH="Pipfile"
    ;;
    poetry)
        PYTHON_INSTALL_ARGS="--no-ansi"
        REQUIREMENTS_PATH="pyproject.toml"
    ;;
esac

if [ -f ${REQUIREMENTS_PATH} ]; then
    echo "INFO: Detected dependency file: $REQUIREMENTS_PATH"
else
    echo "WARNING: No dependency file for ${DETECT_PKG_MNGR:-PARAM_PKG_MNGR} found. ${REQUIREMENTS_PATH} expected."
fi

# Automatically install test package. unittest is preinstalled and not required.
if [ "${PARAM_TEST_TOOL}" != "unittest" ]; then
    DETECT_TEST_TOOL=$(eval "${PYTHON_ENV_TOOL:+$PYTHON_ENV_TOOL run} pip --disable-pip-version-check list" |
    awk 'NR > 2 { print $1 }' | grep "^${PARAM_TEST_TOOL}$")
    
    NOT_DETECTED=$?
    
    if [ $NOT_DETECTED -gt 0 ] && [ "${PARAM_FAIL_IF_MISSING_TOOL}" -eq 1 ]; then
        exit 0
    fi
    
    # If the test package is not detected, install using PYTHON_INSTALL_TOOL
    if [ -z "$DETECT_TEST_TOOL" ]; then
        echo "INFO: Test package ${PARAM_TEST_TOOL} was not found. Installing..."
        eval "${PYTHON_ENV_TOOL:-pip} install ${PYTHON_INSTALL_ARGS} ${PARAM_TEST_TOOL}"
        INSTALL_RESULT=$?
    else
        echo "INFO: Detected test package: $DETECT_TEST_TOOL"
    fi
    
    # If the test package is not detected and PARAM_FAIL_IF_MISSING_TOOL is 0, succeed anyways
    if [ $NOT_DETECTED -gt 0 ] && [ "${PARAM_FAIL_IF_MISSING_TOOL}" -eq 0 ]; then
        exit ${INSTALL_RESULT:-0}
    fi
fi