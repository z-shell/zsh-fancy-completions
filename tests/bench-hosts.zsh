#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

builtin emulate -L zsh
setopt err_exit pipe_fail

typeset repo_dir=${0:A:h:h}
typeset iterations=${ZFC_BENCH_ITERATIONS:-300}
typeset test_home
test_home=$(mktemp -d "${TMPDIR:-/tmp}/zfc-bench-hosts-XXXXXX")
trap 'rm -rf -- "$test_home"' EXIT

zmodload zsh/datetime
typeset -g HOME=$test_home
zstyle ':zfc:config' profile balanced
mkdir -p "$HOME/.ssh/config.d"
source "$repo_dir/zsh-fancy-completions.plugin.zsh"

builtin printf '%-8s %12s %12s\n' files cold-ms cached-ms
typeset size index start elapsed cold cached
for size in 5 20 60; do
  rm -f -- "$HOME/.ssh/config.d"/*.conf(N)
  print -r -- 'Include ~/.ssh/config.d/*.conf' > "$HOME/.ssh/config"
  for (( index = 1; index <= size; ++index )); do
    print -r -- "Host fixture-$index" > "$HOME/.ssh/config.d/$index.conf"
  done

  start=$EPOCHREALTIME
  for (( index = 1; index <= iterations; ++index )); do
    _zfc_refresh_hosts
    _zfc_resolve_hosts
  done
  elapsed=$(( EPOCHREALTIME - start ))
  cold=$(( elapsed * 1000.0 / iterations ))

  _zfc_refresh_hosts
  _zfc_resolve_hosts
  start=$EPOCHREALTIME
  for (( index = 1; index <= iterations; ++index )); do
    _zfc_resolve_hosts
  done
  elapsed=$(( EPOCHREALTIME - start ))
  cached=$(( elapsed * 1000.0 / iterations ))

  builtin printf '%-8d %12.3f %12.3f\n' "$size" "$cold" "$cached"
done

zfc_plugin_unload
