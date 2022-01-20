restore_paths() {
    if [ -f "${1}" ]; then
        rm -rf "${1}"
    fi
    
    mkdir -p "${1}"
    
    if [ -d "${1}" ] && [ -n "$(ls -A 2>/dev/null)" ]; then
        for file in "${1}"/*; do
            echo "INFO: Restoring ${file}"
            decoded=$(basename "${file}" | base64 -d)
            mv "${file}" "${decoded}"
        done
    fi
}

if [ "${PARAM_VENV_CACHE}" = "1" ]; then
    restore_paths "/tmp/venv_cache"
fi

if [ "${PARAM_PYPI_CACHE}" = "1" ]; then
    restore_paths "/tmp/pypi_cache"
fi