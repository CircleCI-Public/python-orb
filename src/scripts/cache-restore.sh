restore_paths() {
    for file in ./*; do
        decoded=$(basename "${file}" | base64 -d)
        mv file "${decoded}"
    done
}

if [ "${PARAM_VENV_CACHE}" = "1" ]; then
    restore_paths "/tmp/venv_cache"
fi

if [ "${PARAM_PYPI_CACHE}" = "1" ]; then
    restore_paths "/tmp/pypi_cache"
fi