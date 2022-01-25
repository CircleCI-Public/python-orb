restore_paths() {
    if [ -d "${1}" ] && [ -n "$(ls -A "${1}" 2>/dev/null)" ]; then
        for file in "${1}"/*; do
            echo "INFO: Restoring ${file}"
            decoded=$(basename "${file}" | base64 -d)
            parent_dir=$(dirname "${decoded}")
            
            # make sure the parent directories exist
            if [ ! -d "${parent_dir}" ]; then
                mkdir -p "${parent_dir}"
            fi
            
            # make sure there isn't anything there already
            if [[ ! -f "${decoded}" && ! -d "${decoded}" ]]; then
                mv "${file}" "${decoded}"
            else
                find "${file}" -name '*' -type f -exec mv -f {} "${decoded}" \;
            fi
        done
    fi
}

CACHE_DIR="/tmp/cci_pycache"

if [ "${PARAM_VENV_CACHE}" = "1" ]; then
    restore_paths "${CACHE_DIR}/venv"
fi

if [ "${PARAM_PYPI_CACHE}" = "1" ]; then
    restore_paths "${CACHE_DIR}/pypi"
fi