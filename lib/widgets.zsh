# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

_zfc_expand_or_complete_with_dots() {
  builtin emulate -L zsh

  if [[ -t 1 && $TERM != dumb ]]; then
    builtin printf '\e[?7l'
    builtin print -Pn -- '%F{red}...%f'
    builtin printf '\e[?7h'
  fi
  zle expand-or-complete
  zle redisplay
}

_zfc_configure_waiting_widget() {
  builtin emulate -L zsh

  local map widget=zfc_expand_or_complete_with_dots
  [[ -o interactive && $TERM != dumb ]] || return 0
  _zfc_feature_enabled waiting-dots || return 0

  _zfc_capture_widget "$widget"
  zle -N "$widget" _zfc_expand_or_complete_with_dots || return
  _zfc_record_applied_widget "$widget"

  for map in emacs viins vicmd; do
    _zfc_capture_binding "$map" '^I'
    bindkey -M "$map" '^I' "$widget" || return
    _zfc_record_applied_binding "$map" '^I'
  done
}

_zfc_enable_bash_compatibility() {
  builtin emulate -L zsh

  local name
  local -a names
  _zfc_feature_enabled bash-compat || {
    builtin print -u2 -r -- 'zfc: bash-compat is not enabled by this profile'
    return 2
  }
  (( ${+_comps} )) || {
    builtin print -u2 -r -- 'zfc: run compinit before enabling Bash compatibility'
    return 3
  }
  (( _zfc_bash_enabled )) && return 0

  names=(bashcompinit _bash_complete compgen complete)
  for name in "${names[@]}"; do
    _zfc_capture_function "$name"
  done
  autoload -Uz +X bashcompinit || return
  bashcompinit || return
  for name in "${names[@]}"; do
    _zfc_record_applied_function "$name"
  done
  _zfc_bash_enabled=1
}

_zfc_configure_optional_runtime() {
  builtin emulate -L zsh

  _zfc_configure_waiting_widget || return
  if _zfc_feature_enabled bash-compat && (( ${+_comps} )); then
    _zfc_enable_bash_compatibility || return
  fi
}
