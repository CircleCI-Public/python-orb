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

link_paths() {
    if [ -d "${1}" ]; then
        echo "Cache directory already exists. Skipping..."
        exit 0
    fi
    
    mkdir -p "${1}"
    
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

if [ "${PARAM_VENV_CACHE}" = "1" ]; then
    link_paths "/tmp/venv_cache" "${VENV_PATHS}"
fi

if [ "${PARAM_PYPI_CACHE}" = "1" ]; then
    link_paths "/tmp/pypi_cache" "${CACHE_PATHS}"
fi

if [ -f "/tmp/lockfile" ]; then
    unlink "/tmp/lockfile"
fi

if [ -f "${LOCK_FILE}" ]; then
    ln "${LOCK_FILE}" "/tmp/lockfile"
fi