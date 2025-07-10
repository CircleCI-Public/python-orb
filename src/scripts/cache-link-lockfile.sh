eval "$SCRIPT_UTILS"
# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"
PARAM_CACHE_FOLDER_PREFIX="$(echo "$PARAM_CACHE_FOLDER_PREFIX" | circleci env subst)"
detect_os
if [[ "$PARAM_CACHE_FOLDER_PREFIX" == /* ]]; then
    if [[ "$PLATFORM" == "windows" ]]; then
        CACHE_PREFIX="/c$PARAM_CACHE_FOLDER_PREFIX"
    else
        CACHE_PREFIX="$PARAM_CACHE_FOLDER_PREFIX"
    fi

else
    CACHE_PREFIX="${PWD%/"$PARAM_APP_DIR"}/$PARAM_CACHE_FOLDER_PREFIX"
fi

    LOCKFILE_PATH="${CACHE_PREFIX%/}/.cci_pycache/lockfile"
mkdir -p "${CACHE_PREFIX}/.cci_pycache/"

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
        uv)
            LOCK_FILE="uv.lock"
        ;;
    esac
    
    if [ -z "${LOCK_FILE}" ]; then
        echo "WARNING: Could not determine lockfile path for ${DETECT_PKG_MNGR:-PARAM_PKG_MNGR}"
    else
        FULL_LOCK_FILE=$(readlink -f "${LOCK_FILE}")

        if [ -f "${LOCK_FILE}" ]; then
            echo "INFO: Copying ${FULL_LOCK_FILE} to ${LOCKFILE_PATH}"
            cp "${FULL_LOCK_FILE}" "${LOCKFILE_PATH}"
        else
            echo "WARNING: Could not find lockfile at ${LOCK_FILE}"
        fi
    fi
fi