
detect_os() {
  detected_platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

  case "$detected_platform" in
    linux*)
      export PLATFORM=linux
      ;;
    darwin*)
      export PLATFORM=macos
      ;;
    msys*|cygwin*)
      export PLATFORM=windows
      ;;
    *)
      printf '%s\n' "Unsupported OS: \"$detected_platform\"."
      exit 1
      ;;
  esac
}