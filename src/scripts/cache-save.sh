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
        VENV_PATHS='[ "/home/circleci/.local/share/virtualenvs" ]'
        CACHE_PATHS='[ "/home/circleci/.cache/pip", "/home/circleci/.cache/pipenv" ]'
    ;;
    poetry)
        LOCK_FILE="${PARAM_APP_DIR}/poetry.lock"
        VENV_PATHS='[ "/home/circleci/.cache/pypoetry/virtualenvs" ]'
        CACHE_PATHS='[ "/home/circleci/.cache/pip" ]'
    ;;
esac

CACHE_DIR="/tmp/pycache"
mkdir -p "${CACHE_DIR}"

link_paths() {
    if [ -d "${1}" ]; then
        echo "Cache directory already exists. Skipping..."
        exit 0
    fi
    
    mkdir "${1}"
    
    for encoded in $(echo "${2}" | jq -r '.[] | @base64'); do
        decoded=$(echo "${encoded}" | base64 -d)
        
        if [ -f "${decoded}" ] || [ -d "${decoded}" ]; then
            echo "Copying ${decoded} to ${1}/${encoded}"
            cp -a "${decoded}" "${1}/${encoded}"
        else
            echo "Could not find ${decoded}. Skipping..."
        fi
        
        ls -la "${1}"
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

if [ -f "${LOCK_FILE}" ]; then
    ln "${LOCK_FILE}" "${LOCKFILE_PATH}"
fi