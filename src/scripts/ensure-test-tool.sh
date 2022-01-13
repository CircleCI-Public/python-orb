case $PARAM_PKG_MNGR in
    pip)
        REQUIREMENTS_PATH="requirements.txt"
    ;;
    pip-dist)
        PYTHON_INSTALL_ARGS="-e"
        REQUIREMENTS_PATH="requirements.txt"
    ;;
    pipenv) # TODO: use PIPENV_PIPFILE
        REQUIREMENTS_PATH="Pipfile"
        PYTHON_ENV_TOOL="pipenv"
    ;;
    poetry)
        REQUIREMENTS_PATH="pyproject.toml"
        PYTHON_ENV_TOOL="poetry"
    ;;
esac

if [ -f ${REQUIREMENTS_PATH} ]; then
    echo "INFO: Detected dependency file: $REQUIREMENTS_PATH"
else
    echo "WARNING: No dependency file for ${PARAM_PKG_MNGR} found. ${REQUIREMENTS_PATH} expected."
fi

# Automatically install test package. unittest is preinstalled and not required.
if [ "${PARAM_TEST_TOOL}" != "unittest" ]; then
    DETECT_TEST_TOOL=$(eval "${PYTHON_ENV_TOOL:+$PYTHON_ENV_TOOL run} pip --disable-pip-version-check list" |
    awk 'NR > 2 { print $1 }' | grep "^${PARAM_TEST_TOOL}$")
    
    NOT_DETECTED=$?
    if [ $NOT_DETECTED -gt 0 ] && [ "${PARAM_FAIL_IF_MISSING_TOOL}" -eq 0 ]; then
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