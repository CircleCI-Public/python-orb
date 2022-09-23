main() {
  local -a build_args

  build_args=(
    --outdir "$PARAM_OUTDIR"
  )
  [[ "$PARAM_SDIST" == 1 ]] && build_args+=( --sdist )
  [[ "$PARAM_WHEEL" == 1 ]] && build_args+=( --wheel )
  [[ "$PARAM_SKIP_DEPENDENCY_CHECK" == 1 ]] && build_args+=( --skip-dependency-check )
  [[ "$PARAM_NO_ISOLATION" == 1 ]] && build_args+=( --no-isolation )

  set -x
  python -m build "${build_args[@]}" .
  set +x

  ls -l "$PARAM_OUTDIR"
}

main "$@"
