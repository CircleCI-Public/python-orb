restore_paths() {
    if [ -d "${1}" ] && [ -n "$(ls -A "${1}" 2>/dev/null)" ]; then
        for file in "${1}"/*; do
            echo "INFO: Restoring ${file}"
            decoded=$(basename "${file}" | base64 -d)
            parent_dir=$(dirname ${decoded})
            
            # make sure the parent directories exist
            if [ ! -d "${parent_dir}" ]; then
                mkdir -p "${parent_dir}"
            fi
            
            # make sure there isn't anything there already
            if [[ ! -f "${decoded}" && ! -d "${decoded}" ]]; then
                mv "${file}" "${decoded}"
            fi
        done
    fi
}

if [ "${PARAM_VENV_CACHE}" = "1" ]; then
    restore_paths "/tmp/venv_cache"
fi

if [ "${PARAM_PYPI_CACHE}" = "1" ]; then
    restore_paths "/tmp/pypi_cache"
fi