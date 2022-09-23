main() {
  local -a build_args

  build_args=(
    --outdir "$PARAM_OUTDIR"
  )
  [[ $PARAM_SDIST == true ]] && build_args+=( --sdist )
  [[ $PARAM_WHEEL == true ]] && build_args+=( --wheel )
  [[ $PARAM_SKIP_DEPENDENCY_CHECK == true ]] && build_args+=( --skip-dependency-check )
  [[ $PARAM_NO_ISOLATION == true ]] && build_args+=( --no-isolation )

  set -x
  python -m build "${build_args[@]}" .
  set +x

  ls -l "$PARAM_OUTDIR"
}

main "$@"
