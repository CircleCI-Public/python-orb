# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"

if [ ! -f "/tmp/lockfile" ]; then
    case ${DETECT_PKG_MNGR:-${PARAM_PKG_MNGR}} in
        pip | pip-dist)
            LOCK_FILE=$(realpath "${PARAM_APP_DIR}"/"${PARAM_DEPENDENCY_FILE:-requirements.txt}")
        ;;
        pipenv)
            LOCK_FILE=$(realpath "${PARAM_APP_DIR}"/Pipfile.lock)
        ;;
        poetry)
            LOCK_FILE=$(realpath "${PARAM_APP_DIR}"/poetry.lock)
        ;;
    esac
    
    if [ -z "${LOCK_FILE}" ]; then
        echo "WARNING: Could not determine lockfile path for ${DETECT_PKG_MNGR:-PARAM_PKG_MNGR}"
    else
      if [ -f "${LOCK_FILE}" ]; then
        echo "INFO: Linking ${LOCK_FILE} to /tmp/lockfile"
        ln "${LOCK_FILE}" "/tmp/lockfile"
      else
        echo "WARNING: Could not find lockfile at ${LOCK_FILE}"
      fi
    fi
fi