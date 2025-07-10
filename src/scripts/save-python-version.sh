eval "$SCRIPT_UTILS"
detect_os
PARAM_CACHE_FOLDER_PREFIX="$(echo "$PARAM_CACHE_FOLDER_PREFIX" | circleci env subst)"

set -x
if [[ "$PARAM_CACHE_FOLDER_PREFIX" == ^/* ]]; then
    if [[ "$PLATFORM" == "windows" ]]; then
        CACHE_PREFIX="/c$PARAM_CACHE_FOLDER_PREFIX"
    else
        CACHE_PREFIX="$PARAM_CACHE_FOLDER_PREFIX"
    fi

else
    CACHE_PREFIX="${PWD%/"$PARAM_APP_SRC_DIR"}/$PARAM_CACHE_FOLDER_PREFIX"
fi

CACHE_DIR="$CACHE_PREFIX/.temp-python-version"
mkdir -p "${CACHE_PREFIX}"
echo "INFO: Copying python version to ${CACHE_DIR}"
python --version | cut -d ' ' -f2 > "$CACHE_DIR" && cat "$CACHE_DIR"