#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

builtin emulate -L zsh
setopt err_exit pipe_fail

typeset scenario=$1 entrypoint=$2

case $scenario in
  noninteractive)
    typeset temp_root
    temp_root=$(mktemp -d "${TMPDIR:-/tmp}/zfc-lifecycle-XXXXXX")
    trap 'rm -rf -- "$temp_root"' EXIT
    typeset -g XDG_CACHE_HOME=$temp_root/cache
    zstyle -L >/dev/null
    typeset before_widget=${+widgets[zfc_expand_or_complete_with_dots]}
    typeset before_options="${(j:,:)${(ok)options}}"
    typeset before_comps=${+_comps}
    source "$entrypoint"
    [[ ${+_comps} == $before_comps ]]
    [[ $(zmodload -L) != *zsh/complist* ]]
    [[ "${(j:,:)${(ok)options}}" == "$before_options" ]]
    [[ ${+widgets[zfc_expand_or_complete_with_dots]} == $before_widget ]]
    [[ ! -e $XDG_CACHE_HOME/zsh-fancy-completions ]]
    zfc_plugin_unload
    ;;
  repeated-source)
    zstyle ':completion:*' menu before-load
    typeset before_styles=$(zstyle -L)
    source "$entrypoint"
    typeset style_count=${#_zfc_applied_styles}
    source "$entrypoint"
    [[ ${#_zfc_applied_styles} == $style_count ]]
    zfc_plugin_unload
    [[ $(zstyle -L) == "$before_styles" ]]
    (( ! ${+functions[zfc_manage]} ))
    (( ! ${+functions[zfc_plugin_unload]} ))
    [[ -z ${(M)${(k)parameters}:#_zfc_*} ]]
    ;;
  hostile-options)
    setopt no_unset glob_subst local_options
    alias zstyle='print caller-zstyle'
    typeset before_options="${(j:,:)${(ok)options}}"
    source "$entrypoint"
    [[ $(alias zstyle) == *caller-zstyle* ]]
    source "$entrypoint"
    zfc_plugin_unload
    [[ $(alias zstyle) == *caller-zstyle* ]]
    [[ "${(j:,:)${(ok)options}}" == "$before_options" ]]
    ;;
  post-load-overrides)
    zfc_manage() { builtin print -r -- original-zfc }
    source "$entrypoint"
    zstyle ':completion:*' menu after-load
    zfc_manage() { builtin print -r -- replacement-zfc }
    zfc_plugin_unload
    [[ $(zstyle -L ':completion:*' menu) == *after-load* ]]
    [[ $(zfc_manage) == replacement-zfc ]]
    ;;
  restore-public-function)
    zfc_manage() { builtin print -r -- original-zfc }
    source "$entrypoint"
    [[ $(zfc_manage features) != original-zfc ]]
    zfc_plugin_unload
    [[ $(zfc_manage) == original-zfc ]]
    ;;
  invalid-feature)
    zstyle ':zfc:config' features core invalid-feature
    typeset before_styles=$(zstyle -L)
    source "$entrypoint" 2>/dev/null && exit 10
    [[ $? == 2 ]]
    [[ $(zstyle -L) == "$before_styles" ]]
    (( ! ${+functions[zfc_manage]} ))
    (( ! ${+functions[zfc_plugin_unload]} ))
    [[ -z ${(M)${(k)parameters}:#_zfc_*} ]]
    ;;
  partial-load)
    typeset temp_root broken_entry load_rc
    temp_root=$(mktemp -d "${TMPDIR:-/tmp}/zfc-partial-XXXXXX")
    trap 'rm -rf -- "$temp_root"' EXIT
    mkdir -p "$temp_root/lib"
    cp -- "$entrypoint" "$temp_root/zsh-fancy-completions.plugin.zsh"
    cp -- "${entrypoint:h}/lib/"*.zsh "$temp_root/lib/"
    rm -- "$temp_root/lib/widgets.zsh"
    broken_entry=$temp_root/zsh-fancy-completions.plugin.zsh
    typeset before_styles=$(zstyle -L)

    if source "$broken_entry" 2>/dev/null; then
      exit 10
    else
      load_rc=$?
    fi

    (( load_rc != 0 ))
    [[ $(zstyle -L) == "$before_styles" ]]
    (( ! ${+functions[zfc_manage]} ))
    (( ! ${+functions[zfc_plugin_unload]} ))
    [[ -z ${(M)${(k)parameters}:#_zfc_*} ]]
    ;;
  profiles)
    typeset profile expected
    for profile expected in \
      minimal 'core' \
      balanced 'core matching corrections colors hosts cache processes' \
      full 'core matching corrections colors hosts cache processes manpages bash-compat waiting-dots'; do
      zstyle ':zfc:config' profile "$profile"
      source "$entrypoint"
      [[ $(zfc_manage features) == "$expected" ]]
      zfc_plugin_unload
    done
    ;;
  doctor)
    zstyle ':zfc:config' profile minimal
    source "$entrypoint"
    typeset before_styles=$(zstyle -L)
    typeset before_modules=$(zmodload -L)
    zfc_manage doctor
    [[ $(zstyle -L) == "$before_styles" ]]
    [[ $(zmodload -L) == "$before_modules" ]]
    zfc_plugin_unload
    ;;
  bash-compat)
    zstyle ':zfc:config' profile full
    autoload -Uz compinit
    compinit -C
    (( ! ${+functions[complete]} ))
    source "$entrypoint"
    (( ${+functions[complete]} ))
    zfc_plugin_unload
    (( ! ${+functions[complete]} ))
    (( ${+_comps} ))
    ;;
  interactive-waiting)
    zsh -f -i "${0:A}" interactive-waiting-case "$entrypoint"
    ;;
  interactive-waiting-case)
    zstyle ':zfc:config' profile full
    typeset -g TERM=xterm-256color
    typeset before_binding=$(bindkey -M emacs '^I')
    typeset before_widget=$(zle -l -L zfc_expand_or_complete_with_dots 2>/dev/null)
    source "$entrypoint"
    [[ $(bindkey -M emacs '^I') == *zfc_expand_or_complete_with_dots* ]]
    [[ -n $(zle -l -L zfc_expand_or_complete_with_dots 2>/dev/null) ]]
    zfc_plugin_unload
    [[ $(bindkey -M emacs '^I') == "$before_binding" ]]
    [[ $(zle -l -L zfc_expand_or_complete_with_dots 2>/dev/null) == "$before_widget" ]]
    ;;
  entrypoint-zero)
    typeset option_mode source_mode
    for option_mode in default no_function_argzero posix_argzero; do
      for source_mode in direct manager_zero; do
        zsh -f "${0:A}" entrypoint-zero-case "$entrypoint" "$option_mode" "$source_mode"
      done
    done
    ;;
  entrypoint-zero-case)
    typeset option_mode=$3 source_mode=$4
    case $option_mode in
      default) ;;
      no_function_argzero) unsetopt function_argzero ;;
      posix_argzero) setopt posix_argzero ;;
    esac
    [[ $source_mode == manager_zero ]] && typeset -g ZERO=$entrypoint
    typeset caller_zero=$0
    source "$entrypoint"
    [[ $0 == "$caller_zero" ]]
    zfc_plugin_unload
    [[ $0 == "$caller_zero" ]]
    ;;
  *)
    builtin print -u2 -r -- "unknown lifecycle scenario: $scenario"
    exit 2
    ;;
esac
