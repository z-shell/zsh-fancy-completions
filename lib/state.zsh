# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

typeset -gA _zfc_original_options _zfc_touched_zstyles _zfc_original_widgets
typeset -gA _zfc_original_bindings _zfc_original_compctls
typeset -ga _zfc_added_fpath _zfc_original_zstyles
typeset -g _zfc_original_plugin_dir _zfc_original_plugin_dir_set
typeset -g _zfc_original_os _zfc_original_os_set

_zfc_capture_state() {
  local option widget map key command

  _zfc_original_plugin_dir_set=${+Plugins[ZF_COMPLETIONS]}
  _zfc_original_plugin_dir=${Plugins[ZF_COMPLETIONS]-}
  _zfc_original_os_set=${+ZFC_OS}
  _zfc_original_os=${ZFC_OS-}
  _zfc_original_zstyles=( "${(@f)$(builtin zstyle -L)}" )

  for option in COMPLETE_IN_WORD ALWAYS_TO_END PATH_DIRS AUTO_MENU AUTO_LIST \
    AUTO_PARAM_SLASH HIST_EXPIRE_DUPS_FIRST EXTENDED_GLOB MENU_COMPLETE FLOW_CONTROL; do
    if [[ -o "$option" ]]; then
      _zfc_original_options[$option]=setopt
    else
      _zfc_original_options[$option]=unsetopt
    fi
  done

  for widget in .complete_menu .expand-or-complete-with-dots; do
    _zfc_original_widgets[$widget]=$(zle -l -L "$widget" 2>/dev/null) ||
      _zfc_original_widgets[$widget]=''
  done

  for map in emacs viins vicmd; do
    key="${map}"$'\x1f''^I'
    _zfc_original_bindings[$key]=$(bindkey -M "$map" '^I' 2>/dev/null) ||
      _zfc_original_bindings[$key]=''
  done

  for command in man ftp lftp ncftp ssh w3m lynx links elinks nc telnet rlogin host finger; do
    _zfc_original_compctls[$command]=$(builtin compctl -L "$command" 2>/dev/null) ||
      _zfc_original_compctls[$command]=''
  done
}

_zfc_add_fpath() {
  local path=$1 position=${2:-append}

  (( ${fpath[(Ie)$path]} )) && return 0
  _zfc_added_fpath+=( "$path" )
  if [[ $position == prepend ]]; then
    fpath=( "$path" "${fpath[@]}" )
  else
    fpath+=( "$path" )
  fi
}

_zfc_zstyle() {
  local context style key

  if [[ $1 == -e ]]; then
    context=$2
    style=$3
  else
    context=$1
    style=$2
  fi
  key="${context}"$'\x1f'"${style}"
  _zfc_touched_zstyles[$key]=1
  builtin zstyle "$@"
}

zsh-fancy-completions_plugin_unload() {
  local key context style snapshot path option widget map binding command

  for key in "${(@k)_zfc_touched_zstyles}"; do
    context=${key%%$'\x1f'*}
    style=${key#*$'\x1f'}
    builtin zstyle -d "$context" "$style"
  done
  for snapshot in "${_zfc_original_zstyles[@]}"; do
    eval "$snapshot"
  done

  for command snapshot in "${(@kv)_zfc_original_compctls}"; do
    builtin compctl + "$command" 2>/dev/null
    [[ -z $snapshot ]] || eval "$snapshot"
  done

  for key binding in "${(@kv)_zfc_original_bindings}"; do
    map=${key%%$'\x1f'*}
    key=${key#*$'\x1f'}
    bindkey -M "$map" -r "$key" 2>/dev/null
    [[ -z $binding ]] || eval "bindkey -M ${(q)map} $binding"
  done

  for widget snapshot in "${(@kv)_zfc_original_widgets}"; do
    zle -D "$widget" 2>/dev/null || true
    [[ -z $snapshot ]] || eval "$snapshot"
  done

  for option snapshot in "${(@kv)_zfc_original_options}"; do
    "$snapshot" "$option"
  done

  for path in "${_zfc_added_fpath[@]}"; do
    fpath=( "${fpath[@]:#$path}" )
  done

  if (( _zfc_original_plugin_dir_set )); then
    Plugins[ZF_COMPLETIONS]=$_zfc_original_plugin_dir
  else
    unset 'Plugins[ZF_COMPLETIONS]'
  fi
  if (( _zfc_original_os_set )); then
    ZFC_OS=$_zfc_original_os
  else
    unset ZFC_OS
  fi

  unfunction _zfc_capture_state _zfc_add_fpath _zfc_zstyle
  unset _zfc_original_options _zfc_touched_zstyles _zfc_original_zstyles
  unset _zfc_original_widgets
  unset _zfc_original_bindings _zfc_original_compctls _zfc_added_fpath
  unset _zfc_original_plugin_dir _zfc_original_plugin_dir_set
  unset _zfc_original_os _zfc_original_os_set
  unfunction zsh-fancy-completions_plugin_unload
}
