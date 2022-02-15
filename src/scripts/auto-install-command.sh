# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"

case ${DETECT_PKG_MNGR:-${PARAM_PKG_MNGR}} in
    pip)
        PYTHON_INSTALL_ARGS="-r ${PARAM_DEPENDENCY_FILE:-requirements.txt}"
    ;;
    pip-dist)
        PYTHON_INSTALL_ARGS="-e ${PARAM_PATH_ARGS}"
    ;;
    poetry)
        PYTHON_INSTALL_ARGS="--no-ansi"
    ;;
esac

eval "${PYTHON_ENV_TOOL:-pip} install ${PYTHON_INSTALL_ARGS} ${PARAM_ADDITIONAL_ARGS}"