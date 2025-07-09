eval "$SCRIPT_UTILS"
detect_os
PARAM_CACHE_FOLDER_PREFIX="$(echo "$PARAM_CACHE_FOLDER_PREFIX" | circleci env subst)"
if [[ "$PARAM_APP_SRC_DIR" == ~* ]]; then
    PARAM_APP_SRC_DIR="$HOME${PARAM_APP_SRC_DIR:1}"
fi
if [[ "$PARAM_CACHE_FOLDER_PREFIX" == /* ]]; then
    if [[ "$PLATFORM" == "windows" ]]; then
        CACHE_PREFIX="/c$PARAM_CACHE_FOLDER_PREFIX"
    else
        CACHE_PREFIX="$PARAM_CACHE_FOLDER_PREFIX"
    fi

else
    CACHE_PREFIX="${PWD%/"$PARAM_APP_SRC_DIR"}/$PARAM_CACHE_FOLDER_PREFIX"
fi

CACHE_DIR="$CACHE_PREFIX.temp-python-version"


python --version | cut -d ' ' -f2 > "$CACHE_DIR" && cat "$CACHE_DIR"