local -a build_args
build_args=(
  --outdir "$PARAM_OUTDIR"
)
[[ $PARAM_SDIST ]] && build_args+=( --sdist )
[[ $PARAM_WHEEL ]] && build_args+=( --wheel )
[[ $PARAM_SKIP_DEPENDENCY_CHECK ]] && build_args+=( --skip-dependency-check )
[[ $PARAM_NO_ISOLATION ]] && build_args+=( --no-isolation )

python -m build "${build_args[@]}" .
ls -l "$PARAM_OUTDIR"
