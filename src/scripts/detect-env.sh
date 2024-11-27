if [ "${PARAM_PKG_MNGR}" = "auto" ]; then
    if [ -f "requirements.txt" ]; then
        if [ -f "${PARAM_SETUP_FILE_PATH:-setup.py}" ]; then
            export DETECT_PKG_MNGR="pip-dist"
        else
            export DETECT_PKG_MNGR="pip"
        fi
        elif [ -f "Pipfile" ]; then
        export DETECT_PKG_MNGR="pipenv"
        export PYTHON_ENV_TOOL="pipenv"
        elif [ -f "uv.lock" ]; then
        export DETECT_PKG_MNGR="uv"
        export PYTHON_ENV_TOOL="uv"
        elif [ -f "pyproject.toml" ]; then
        export DETECT_PKG_MNGR="poetry"
        export PYTHON_ENV_TOOL="poetry"
    fi
    
    echo "INFO: Detected Package Manager ${DETECT_PKG_MNGR}"
fi