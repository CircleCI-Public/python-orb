# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"
LOCKFILE_PATH="/tmp/pycache/lockfile"

if [ ! -f "${LOCKFILE_PATH}" ]; then
    eval PARAM_APP_DIR="${PARAM_APP_DIR}"
    
    case ${DETECT_PKG_MNGR:-${PARAM_PKG_MNGR}} in
        pip | pip-dist)
            LOCK_FILE="${PARAM_APP_DIR}/${PARAM_DEPENDENCY_FILE:-requirements.txt}"
        ;;
        pipenv)
            LOCK_FILE="${PARAM_APP_DIR}/Pipfile.lock"
        ;;
        poetry)
            LOCK_FILE="${PARAM_APP_DIR}/poetry.lock"
        ;;
    esac
    
    if [ -z "${LOCK_FILE}" ]; then
        echo "WARNING: Could not determine lockfile path for ${DETECT_PKG_MNGR:-PARAM_PKG_MNGR}"
    else
        if [ -f "${LOCK_FILE}" ]; then
            echo "INFO: Linking ${LOCK_FILE} to ${LOCKFILE_PATH}"
            ln -s "${LOCK_FILE}" "${LOCKFILE_PATH}"
        else
            echo "WARNING: Could not find lockfile at ${LOCK_FILE}"
        fi
    fi
fi