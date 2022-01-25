# credit for recurse function: https://github.com/antichris
recurse() {
    if [ ! -d "$1" ] || [ ! -e "$2" ]; then
        mv -u "$1" "$2" || exit
        return
    fi
    for entry in "$1/"* "$1/."[!.]* "$1/.."?*; do
        if [ -e "$entry" ]; then
            recurse "$entry" "$2/${entry##"$1/"}"
        fi
    done
}

restore_paths() {
    if [ -d "${1}" ] && [ -n "$(ls -A "${1}" 2>/dev/null)" ]; then
        for file in "${1}"/*; do
            decoded=$(basename "${file}" | base64 -d)
            parent_dir=$(dirname "${decoded}")
            
            # make sure the parent directories exist
            if [ ! -d "${parent_dir}" ]; then
                mkdir -p "${parent_dir}"
            fi
            
            echo "INFO: Restoring ${file} to ${decoded}"

            recurse "${file}" "${decoded}"
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