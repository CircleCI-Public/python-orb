# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"

if [ "${PARAM_TEST_TOOL}" = "pytest" ]; then
    INSTALL_COMMAND="pytest --junit-xml=test-report/report.xml ${PARAM_TEST_TOOL_ARGS}"
else 
    INSTALL_COMMAND="python -m unittest ${PARAM__ARGS}"
fi

if [ -n "${PYTHON_ENV_TOOL}" ]; then
    eval "${PYTHON_ENV_TOOL} run ${INSTALL_COMMAND}"
else
    eval "${INSTALL_COMMAND}"
fi