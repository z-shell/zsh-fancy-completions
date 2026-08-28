# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# This library defines the ownership boundary used by load, unload, and doctor.
# It intentionally has no top-level side effects other than function definitions.

_zfc_feature_enabled() {
  builtin emulate -L zsh

  (( ${_zfc_features[(Ie)$1]} ))
}

_zfc_prepare_configuration() {
  builtin emulate -L zsh

  local profile feature cache_dir
  local -a requested resolved valid
  local -A seen

  valid=(core matching corrections colors hosts cache processes manpages
    bash-compat waiting-dots)

  builtin zstyle -s ':zfc:config' profile profile || profile=balanced
  if builtin zstyle -a ':zfc:config' features requested; then
    :
  else
    case $profile in
      minimal)
        requested=(core)
        ;;
      balanced)
        requested=(core matching corrections colors hosts cache processes)
        ;;
      full)
        requested=(core matching corrections colors hosts cache processes
          manpages bash-compat waiting-dots)
        ;;
      *)
        builtin print -u2 -r -- "zsh-fancy-completions: unknown profile: $profile"
        return 2
        ;;
    esac
  fi

  for feature in "${requested[@]}"; do
    if (( ! ${valid[(Ie)$feature]} )); then
      builtin print -u2 -r -- "zsh-fancy-completions: unknown feature: $feature"
      return 2
    fi
    (( ${+seen[$feature]} )) && continue
    seen[$feature]=1
    resolved+=("$feature")
  done

  builtin zstyle -s ':zfc:config' cache-dir cache_dir ||
    cache_dir=${XDG_CACHE_HOME:-${ZDOTDIR:-$HOME/.cache}}/zsh-fancy-completions
  if (( ${resolved[(Ie)cache]} )) && [[ -z $cache_dir ]]; then
    builtin print -u2 -r -- 'zsh-fancy-completions: cache path must not be empty'
    return 2
  fi

  typeset -g _zfc_profile=$profile
  typeset -ga _zfc_features=("${resolved[@]}")
  typeset -g _zfc_cache_dir=${cache_dir:A}
}

_zfc_capture_function() {
  builtin emulate -L zsh

  local name=$1
  (( ${+_zfc_original_function_set[$name]} )) && return 0

  _zfc_original_function_set[$name]=${+functions[$name]}
  _zfc_original_functions[$name]=${functions[$name]-}
}

_zfc_record_applied_function() {
  builtin emulate -L zsh

  local name=$1
  _zfc_applied_functions[$name]=${functions[$name]-}
}

_zfc_capture_state() {
  builtin emulate -L zsh

  typeset -gA _zfc_original_styles=() _zfc_applied_styles=()
  typeset -gA _zfc_touched_styles=() _zfc_initial_styles=() _zfc_style_index=()
  typeset -gA _zfc_original_function_set=() _zfc_original_functions=()
  typeset -gA _zfc_applied_functions=() _zfc_added_fpath=()
  typeset -gA _zfc_original_widgets=() _zfc_applied_widgets=()
  typeset -gA _zfc_original_bindings=() _zfc_applied_bindings=()
  typeset -gA _zfc_owned_modules=()
  typeset -ga _zfc_host_cache=() _zfc_host_sources=() _zfc_host_watch_dirs=()
  typeset -g _zfc_host_signature='' _zfc_host_cache_home=''
  typeset -g _zfc_bash_enabled=0 _zfc_loaded=0

  _zfc_capture_function zfc_manage
  _zfc_index_styles
  _zfc_initial_styles=("${(@kv)_zfc_style_index}")
}

_zfc_index_styles() {
  builtin emulate -L zsh

  local line stored_context stored_style key
  local -a fields
  _zfc_style_index=()
  for line in "${(@f)$(builtin zstyle -L)}"; do
    fields=(${(z)line})
    (( $#fields >= 3 )) || continue
    if [[ $fields[2] == -e ]]; then
      stored_context=${(Q)fields[3]}
      stored_style=${(Q)fields[4]}
    else
      stored_context=${(Q)fields[2]}
      stored_style=${(Q)fields[3]}
    fi
    key="${stored_context}"$'\x1f'"${stored_style}"
    _zfc_style_index[$key]=$line
  done
}

_zfc_style() {
  builtin emulate -L zsh

  local context style key
  if [[ $1 == -e ]]; then
    context=$2
    style=$3
  else
    context=$1
    style=$2
  fi
  key="${context}"$'\x1f'"${style}"

  if (( ! ${+_zfc_touched_styles[$key]} )); then
    _zfc_touched_styles[$key]=1
    _zfc_original_styles[$key]=${_zfc_initial_styles[$key]-}
  fi

  builtin zstyle "$@" || return
  return 0
}

_zfc_finalize_styles() {
  builtin emulate -L zsh

  local key
  _zfc_index_styles
  for key in "${(@k)_zfc_touched_styles}"; do
    _zfc_applied_styles[$key]=${_zfc_style_index[$key]-}
  done
}

_zfc_restore_style_snapshot() {
  builtin emulate -L zsh

  local snapshot=$1
  local -a fields
  [[ -n $snapshot ]] || return 0
  fields=(${(z)snapshot})
  [[ ${(Q)fields[1]} == zstyle ]] || return 1
  builtin zstyle "${(@Q)fields[2,-1]}"
}

_zfc_add_fpath() {
  builtin emulate -L zsh

  local path=$1 position=${2:-append}
  (( ${fpath[(Ie)$path]} )) && return 0

  _zfc_added_fpath[$path]=$position
  if [[ $position == prepend ]]; then
    fpath=("$path" "${fpath[@]}")
  else
    fpath+=("$path")
  fi
}

_zfc_capture_widget() {
  builtin emulate -L zsh

  local widget=$1
  _zfc_original_widgets[$widget]=$(zle -l -L "$widget" 2>/dev/null) ||
    _zfc_original_widgets[$widget]=''
}

_zfc_record_applied_widget() {
  builtin emulate -L zsh

  local widget=$1
  _zfc_applied_widgets[$widget]=$(zle -l -L "$widget" 2>/dev/null) ||
    _zfc_applied_widgets[$widget]=''
}

_zfc_capture_binding() {
  builtin emulate -L zsh

  local map=$1 key=$2 state_key="${1}"$'\x1f'"${2}"
  _zfc_original_bindings[$state_key]=$(bindkey -M "$map" "$key" 2>/dev/null) ||
    _zfc_original_bindings[$state_key]=''
}

_zfc_record_applied_binding() {
  builtin emulate -L zsh

  local map=$1 key=$2 state_key="${1}"$'\x1f'"${2}"
  _zfc_applied_bindings[$state_key]=$(bindkey -M "$map" "$key" 2>/dev/null) ||
    _zfc_applied_bindings[$state_key]=''
}

_zfc_restore_styles() {
  builtin emulate -L zsh

  local key context style current snapshot
  _zfc_index_styles
  for key in "${(@k)_zfc_applied_styles}"; do
    context=${key%%$'\x1f'*}
    style=${key#*$'\x1f'}
    current=${_zfc_style_index[$key]-}
    [[ $current == "${_zfc_applied_styles[$key]}" ]] || continue

    builtin zstyle -d "$context" "$style"
    snapshot=${_zfc_original_styles[$key]}
    _zfc_restore_style_snapshot "$snapshot"
  done
}

_zfc_restore_widgets() {
  builtin emulate -L zsh

  local widget current snapshot key map binding
  for widget in "${(@k)_zfc_applied_widgets}"; do
    current=$(zle -l -L "$widget" 2>/dev/null) || current=''
    [[ $current == "${_zfc_applied_widgets[$widget]}" ]] || continue

    zle -D "$widget" 2>/dev/null || true
    snapshot=${_zfc_original_widgets[$widget]}
    if [[ -n $snapshot ]]; then
      local -a widget_fields
      widget_fields=(${(z)snapshot})
      [[ ${(Q)widget_fields[1]} == zle ]] || return 1
      zle "${(@Q)widget_fields[2,-1]}"
    fi
  done

  for key in "${(@k)_zfc_applied_bindings}"; do
    map=${key%%$'\x1f'*}
    binding=${key#*$'\x1f'}
    current=$(bindkey -M "$map" "$binding" 2>/dev/null) || current=''
    [[ $current == "${_zfc_applied_bindings[$key]}" ]] || continue

    bindkey -M "$map" -r "$binding" 2>/dev/null || true
    snapshot=${_zfc_original_bindings[$key]}
    if [[ -n $snapshot ]]; then
      local -a binding_fields
      binding_fields=(${(z)snapshot})
      bindkey -M "$map" "${(@Q)binding_fields}"
    fi
  done
}

_zfc_restore_functions() {
  builtin emulate -L zsh

  local name
  for name in "${(@k)_zfc_applied_functions}"; do
    [[ ${functions[$name]-} == "${_zfc_applied_functions[$name]}" ]] || continue
    if (( _zfc_original_function_set[$name] )); then
      functions[$name]=${_zfc_original_functions[$name]}
    else
      unfunction "$name" 2>/dev/null || true
    fi
  done
}

_zfc_remove_fpath() {
  builtin emulate -L zsh

  local path index
  for path in "${(@k)_zfc_added_fpath}"; do
    index=${fpath[(i)$path]}
    (( index <= $#fpath )) && fpath[$index]=()
  done
}

zfc_plugin_unload() {
  builtin emulate -L zsh

  local module name
  local -a private_functions

  _zfc_restore_styles
  [[ -o interactive ]] && _zfc_restore_widgets
  _zfc_restore_functions
  _zfc_remove_fpath

  for module in "${(@k)_zfc_owned_modules}"; do
    zmodload -u "$module" 2>/dev/null || true
  done

  private_functions=(${(M)${(k)functions}:#_zfc_*})
  for name in "${private_functions[@]}"; do
    unfunction "$name" 2>/dev/null || true
  done
  unset _zfc_host_signature _zfc_added_fpath _zfc_applied_bindings
  unset _zfc_features _zfc_original_function_set
  unset _zfc_applied_functions _zfc_owned_modules
  unset _zfc_cache_dir _zfc_host_cache _zfc_host_cache_home
  unset _zfc_original_styles _zfc_touched_styles _zfc_initial_styles
  unset _zfc_style_index _zfc_bash_enabled
  unset _zfc_host_sources _zfc_original_widgets _zfc_applied_styles
  unset _zfc_applied_widgets _zfc_loaded _zfc_host_watch_dirs
  unset _zfc_original_functions _zfc_profile _zfc_original_bindings
  unfunction zfc_plugin_unload
}
