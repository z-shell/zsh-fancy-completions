#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

builtin emulate -L zsh
setopt err_exit pipe_fail

typeset scenario=$1 entrypoint=$2
typeset -g HOME=$3
typeset -gA Plugins
typeset -a resolved

case $scenario in
  syntax)
    source "$entrypoint"
    zstyle -a ':completion:*:hosts' hosts resolved
    typeset expected
    for expected in direct-host uppercase-host included-host included-alias \
      nested-host relative-host spaced-host literal-bracket-host extensionless-host; do
      (( ${resolved[(Ie)$expected]} ))
    done
    for expected in negated-host 'wildcard-*' match-only should-not-match-quoted-include; do
      (( ! ${resolved[(Ie)$expected]} ))
    done
    zsh-fancy-completions_plugin_unload
    ;;
  invalidation)
    source "$entrypoint"
    zstyle -a ':completion:*:hosts' hosts resolved
    _zfc_host_cache+=(cache-sentinel)
    zstyle -a ':completion:*:hosts' hosts resolved
    (( ${resolved[(Ie)cache-sentinel]} ))
    print -r -- 'Host changed-host' >> "$HOME/.ssh/config.d/network.conf"
    zstyle -a ':completion:*:hosts' hosts resolved
    (( ! ${resolved[(Ie)cache-sentinel]} ))
    (( ${resolved[(Ie)changed-host]} ))
    zsh-fancy-completions_plugin_unload
    ;;
  refresh)
    source "$entrypoint"
    zstyle -a ':completion:*:hosts' hosts resolved
    [[ -n $_zfc_host_signature ]]
    zfc refresh hosts >/dev/null
    [[ -z $_zfc_host_signature && $#_zfc_host_cache == 0 ]]
    zsh-fancy-completions_plugin_unload
    ;;
  module-ownership)
    if zmodload -e zsh/stat; then
      exit 10
    fi
    source "$entrypoint"
    zstyle -a ':completion:*:hosts' hosts resolved
    zmodload -e zsh/stat
    zsh-fancy-completions_plugin_unload
    if zmodload -e zsh/stat; then
      exit 11
    fi
    ;;
  *)
    builtin print -u2 -r -- "unknown hosts scenario: $scenario"
    exit 2
    ;;
esac
