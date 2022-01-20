# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"

if [ "${PARAM_TEST_TOOL}" = "pytest" ]; then
    INSTALL_COMMAND="pytest --junit-xml=test-report/report.xml ${PARAM_ADDITIONAL_ARGS}"
else 
    INSTALL_COMMAND="python -m unittest ${PARAM__ARGS}"
fi

if [ "${DETECT_PKG_MNGR}" = "pipenv" ] || [ "${DETECT_PKG_MNGR}" = "poetry" ]; then
    eval "${PYTHON_ENV_TOOL} run ${INSTALL_COMMAND}"
else
    eval "${INSTALL_COMMAND}"
fi