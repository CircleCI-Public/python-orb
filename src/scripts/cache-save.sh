# shellcheck source=detect-env.sh
source "$AUTO_DETECT_ENV_SCRIPT"
eval PARAM_APP_DIR="${PARAM_APP_DIR}"

case ${DETECT_PKG_MNGR:-${PARAM_PKG_MNGR}} in
    pip | pip-dist)
        LOCK_FILE="${PARAM_APP_DIR}/${PARAM_DEPENDENCY_FILE:-requirements.txt}"
        CACHE_PATHS='[ "/home/circleci/.cache/pip", "/home/circleci/.pyenv/versions", "/home/circleci/.local/lib" ]'
    ;;
    pipenv) # TODO: use PIPENV_PIPFILE
        LOCK_FILE="${PARAM_APP_DIR}/Pipfile.lock"
        PIPENV_VENV_PATH="${WORKON_HOME:-/home/circleci/.local/share/virtualenvs}"

        if [ -z "${PIPENV_VENV_IN_PROJECT}" ]; then
            VENV_PATHS="[ \"${PIPENV_VENV_PATH}\" ]"
        else
            VENV_PATHS="[ \"${PARAM_APP_DIR}/.venvs\" ]"
        fi
        
        CACHE_PATHS='[ "/home/circleci/.cache/pip", "/home/circleci/.cache/pipenv" ]'
    ;;
    poetry)
        LOCK_FILE="${PARAM_APP_DIR}/poetry.lock"
        VENV_PATHS='[ "/home/circleci/.cache/pypoetry/virtualenvs" ]'
        CACHE_PATHS='[ "/home/circleci/.cache/pip" ]'
    ;;
esac

if [ -n "${PARAM_VENV_PATH}" ]; then
    VENV_PATHS="${PARAM_VENV_PATH}"
fi

CACHE_DIR="/tmp/cci_pycache"
mkdir -p "${CACHE_DIR}"

link_paths() {
    if [ -d "${1}" ]; then
        echo "INFO: Cache directory already exists. Skipping..."
        return
    fi
    
    mkdir "${1}"

    for encoded in $(echo "${2}" | jq -r '.[] | @base64'); do
        decoded=$(echo "${encoded}" | base64 -d)
        
        if [ -e "${decoded}" ]; then
            echo "INFO: Copying ${decoded} to ${1}/${encoded}"
            cp -a "${decoded}" "${1}/${encoded}"
        else
            echo "INFO: Could not find ${decoded}. Skipping..."
        fi
    done
}

if [ "${PARAM_VENV_CACHE}" = "1" ] && [ -n "${VENV_PATHS}" ]; then
    link_paths "${CACHE_DIR}/venv" "${VENV_PATHS}"
fi

if [ "${PARAM_PYPI_CACHE}" = "1" ]; then
    link_paths "${CACHE_DIR}/pypi" "${CACHE_PATHS}"
fi

LOCKFILE_PATH="${CACHE_DIR}/lockfile"

if [ -f "${LOCKFILE_PATH}" ]; then
    unlink "${LOCKFILE_PATH}"
fi

readlink -f -v "${LOCK_FILE}"
if [ -e "${LOCK_FILE}" ]; then
    
    echo "INFO: Linking ${FULL_LOCK_FILE} to ${LOCKFILE_PATH}"
    ln -s "${FULL_LOCK_FILE}" "${LOCKFILE_PATH}"
fi