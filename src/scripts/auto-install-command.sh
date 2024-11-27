# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"

case ${DETECT_PKG_MNGR:-${PARAM_PKG_MNGR}} in
    pip)
        PYTHON_INSTALL_ARGS="-r ${PARAM_DEPENDENCY_FILE:-requirements.txt}"
        eval "${PYTHON_ENV_TOOL:-pip} install ${PYTHON_INSTALL_ARGS} ${PARAM_ADDITIONAL_ARGS}"
    ;;
    pip-dist)
        PYTHON_INSTALL_ARGS="-e ${PARAM_PATH_ARGS}"
        eval "${PYTHON_ENV_TOOL:-pip} install ${PYTHON_INSTALL_ARGS} ${PARAM_ADDITIONAL_ARGS}"
    ;;
    poetry)
        PYTHON_INSTALL_ARGS="--no-ansi"
        eval "poetry install ${PYTHON_INSTALL_ARGS} ${PARAM_ADDITIONAL_ARGS}"
    ;;
    uv)
        PYTHON_INSTALL_ARGS=""
        eval "uv sync ${PYTHON_INSTALL_ARGS} ${PARAM_ADDITIONAL_ARGS}"
    ;;
esac
