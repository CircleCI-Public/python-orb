# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"

CACHE_DIR="/tmp/cci_pycache"
LOCKFILE_PATH="${CACHE_DIR}/lockfile"

mkdir -p "${CACHE_DIR}"

if [ ! -f "${LOCKFILE_PATH}" ]; then
    case ${DETECT_PKG_MNGR:-${PARAM_PKG_MNGR}} in
        pip | pip-dist)
            LOCK_FILE="${PARAM_DEPENDENCY_FILE:-requirements.txt}"
        ;;
        pipenv)
            LOCK_FILE="Pipfile.lock"
        ;;
        poetry)
            LOCK_FILE="poetry.lock"
        ;;
    esac
    
    if [ -z "${LOCK_FILE}" ]; then
        echo "WARNING: Could not determine lockfile path for ${DETECT_PKG_MNGR:-PARAM_PKG_MNGR}"
    else
        FULL_LOCK_FILE=$(readlink -f -v "${LOCK_FILE}")

        if [ -f "${LOCK_FILE}" ]; then
            echo "INFO: Copying ${FULL_LOCK_FILE} to ${LOCKFILE_PATH}"
            cp "${FULL_LOCK_FILE}" "${LOCKFILE_PATH}"
        else
            echo "WARNING: Could not find lockfile at ${LOCK_FILE}"
        fi
    fi
fi