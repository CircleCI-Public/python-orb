restore_paths() {
    if [ -f "${1}" ]; then
        rm -rf "${1}"
    fi
    
    mkdir -p "${1}"
    
    if [ -d "${1}" ]; then
        for file in "${1}"/*; do
            decoded=$(basename "${file}" | base64 -d)
            mv "${file}" "${decoded}"
            echo "INFO: Restoring ${file} to ${decoded}"
        done
    fi
}

if [ "${PARAM_VENV_CACHE}" = "1" ]; then
    restore_paths "/tmp/venv_cache"
fi

if [ "${PARAM_PYPI_CACHE}" = "1" ]; then
    restore_paths "/tmp/pypi_cache"
fi