"$AUTO_DETECT_ENV_SCRIPT"

if [ ! -f "/tmp/lockfile" ]; then
    case ${DETECT_PKG_MNGR:-PARAM_PKG_MNGR} in
        pip | pip-dist)
            LOCK_FILE="${PARAM_APP_DIR}/${PARAM_DEPENDENCY_FILE:-requirements.txt}"
        ;;
        pipenv) # TODO: use PIPENV_PIPFILE
            LOCK_FILE="${PARAM_APP_DIR}/Pipfile.lock"
        ;;
        poetry)
            LOCK_FILE="${PARAM_APP_DIR}/poetry.lock"
        ;;
    esac
    
    ln -s "${LOCK_FILE}" "/tmp/lockfile"
fi