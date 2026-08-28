# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

_zfc_doctor_line() {
  builtin emulate -L zsh

  builtin printf '%-5s %s\n' "$1" "$2"
}

_zfc_doctor() {
  builtin emulate -L zsh

  local cache_parent=$_zfc_cache_dir key context style current widget map binding
  local errors=0 drift=0
  local -a insecure

  _zfc_doctor_line info "profile: $_zfc_profile"
  _zfc_doctor_line info "features: ${(j:, :)_zfc_features}"

  if (( ${+_comps} )); then
    _zfc_doctor_line ok 'completion system initialized'
  else
    _zfc_doctor_line warn 'completion system not initialized; run compinit after loading completion definitions'
  fi

  if _zfc_feature_enabled cache; then
    while [[ ! -e $cache_parent && $cache_parent != / ]]; do
      cache_parent=${cache_parent:h}
    done
    if [[ -d $cache_parent && -w $cache_parent ]]; then
      _zfc_doctor_line ok "cache path can be created lazily: $_zfc_cache_dir"
    else
      _zfc_doctor_line error "cache parent is not writable: $cache_parent"
      (( ++errors ))
    fi
  else
    _zfc_doctor_line info 'cache feature disabled'
  fi

  insecure=("${(@f)$(
    autoload -Uz compaudit 2>/dev/null && compaudit 2>/dev/null
  )}")
  insecure=("${insecure:#}")
  if (( $#insecure )); then
    _zfc_doctor_line error "insecure fpath entries: ${(j:, :)insecure}"
    (( ++errors ))
  else
    _zfc_doctor_line ok 'no insecure fpath entries reported by compaudit'
  fi

  _zfc_index_styles
  for key in "${(@k)_zfc_applied_styles}"; do
    context=${key%%$'\x1f'*}
    style=${key#*$'\x1f'}
    current=${_zfc_style_index[$key]-}
    [[ $current == "${_zfc_applied_styles[$key]}" ]] || (( ++drift ))
  done
  if (( drift )); then
    _zfc_doctor_line warn "$drift plugin-applied completion styles changed after load"
  else
    _zfc_doctor_line ok 'plugin-applied completion styles are unchanged'
  fi

  if _zfc_feature_enabled waiting-dots; then
    if [[ ! -o interactive ]]; then
      _zfc_doctor_line info 'waiting-dots deferred in this non-interactive shell'
    else
      widget=zfc-expand-or-complete-with-dots
      current=$(zle -l -L "$widget" 2>/dev/null) || current=''
      if [[ $current == "${_zfc_applied_widgets[$widget]-}" ]]; then
        _zfc_doctor_line ok 'waiting-dots widget is installed'
      else
        _zfc_doctor_line warn 'waiting-dots widget was replaced after load'
      fi
      for map in emacs viins vicmd; do
        key="${map}"$'\x1f''^I'
        binding=$(bindkey -M "$map" '^I' 2>/dev/null) || binding=''
        [[ $binding == "${_zfc_applied_bindings[$key]-}" ]] ||
          _zfc_doctor_line warn "Tab binding differs in keymap $map"
      done
    fi
  fi

  if _zfc_feature_enabled bash-compat; then
    if (( _zfc_bash_enabled )); then
      _zfc_doctor_line ok 'Bash compatibility enabled'
    elif (( ${+_comps} )); then
      _zfc_doctor_line warn 'Bash compatibility deferred; run: zfc enable bash'
    else
      _zfc_doctor_line info 'Bash compatibility waits for compinit'
    fi
  fi

  if zmodload -e zsh/stat; then
    _zfc_doctor_line ok 'zsh/stat module loaded for host-cache invalidation'
  else
    _zfc_doctor_line info 'zsh/stat will load on the first host resolution'
  fi
  if zmodload -e zsh/complete; then
    _zfc_doctor_line ok 'zsh/complete module loaded for completion styles'
  else
    _zfc_doctor_line warn 'zsh/complete module is not loaded'
  fi
  if _zfc_feature_enabled waiting-dots && [[ -o interactive ]]; then
    if zmodload -e zsh/zle; then
      _zfc_doctor_line ok 'zsh/zle module loaded for waiting-dots'
    else
      _zfc_doctor_line warn 'zsh/zle module is not loaded'
    fi
  fi

  return $(( errors > 0 ))
}

_zfc_prepare_cache() {
  builtin emulate -L zsh

  mkdir -p -- "$_zfc_cache_dir" || return
  builtin print -r -- "$_zfc_cache_dir"
}

zfc() {
  builtin emulate -L zsh

  local command=${1:-help} target=${2:-all}
  case $command in
    doctor)
      _zfc_doctor
      ;;
    features)
      builtin print -r -- "${_zfc_features[@]}"
      ;;
    cache-path)
      builtin print -r -- "$_zfc_cache_dir"
      ;;
    prepare-cache)
      _zfc_prepare_cache
      ;;
    refresh)
      case $target in
        all | hosts)
          _zfc_refresh_hosts
          builtin print -r -- 'zfc: host cache cleared'
          ;;
        *)
          builtin print -u2 -r -- "zfc: unknown refresh target: $target"
          return 2
          ;;
      esac
      ;;
    enable)
      case $target in
        bash) _zfc_enable_bash_compatibility ;;
        *)
          builtin print -u2 -r -- "zfc: unknown runtime feature: $target"
          return 2
          ;;
      esac
      ;;
    help | -h | --help)
      builtin print -r -- 'usage: zfc doctor|features|cache-path|prepare-cache|refresh [hosts]|enable bash'
      ;;
    *)
      builtin print -u2 -r -- "zfc: unknown command: $command"
      return 2
      ;;
  esac
}
