# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# Resolve the source path without assigning to special parameter 0.
() {
  builtin emulate -L zsh

  local source_path plugin_dir library name rc=0 finalize_rc=0
  local -a libraries private_functions

  source_path="${${(M)1:#/*}:-$PWD/$1}"
  plugin_dir=${source_path:A:h}

  if (( ${+Plugins} )) && [[ ${(t)Plugins} != *association* ]]; then
    builtin print -u2 -r -- 'zsh-fancy-completions: Plugins must be an associative array'
    return 2
  fi

  if [[ ${Plugins[ZF_COMPLETIONS]-} == $plugin_dir ]] &&
    (( ${+functions[zsh-fancy-completions_plugin_unload]} )); then
    return 0
  fi
  if (( ${+functions[zsh-fancy-completions_plugin_unload]} )); then
    builtin print -u2 -r -- 'zsh-fancy-completions: unload function already exists'
    return 2
  fi

  builtin source "$plugin_dir/lib/state.zsh" || return
  _zfc_prepare_configuration
  rc=$?
  if (( rc )); then
    private_functions=(${(M)${(k)functions}:#_zfc_*})
    for name in "${private_functions[@]}"; do
      unfunction "$name" 2>/dev/null || true
    done
    unfunction zsh-fancy-completions_plugin_unload 2>/dev/null || true
    return "$rc"
  fi

  typeset -gA Plugins
  _zfc_capture_state
  typeset -g _zfc_plugin_dir=$plugin_dir
  Plugins[ZF_COMPLETIONS]=$plugin_dir

  libraries=(compatibility hosts completion widgets doctor)
  for library in "${libraries[@]}"; do
    builtin source "$plugin_dir/lib/$library.zsh" || {
      rc=$?
      break
    }
  done

  if (( ! rc )); then
    _zfc_record_applied_function zfc
    _zfc_apply_compatibility || rc=$?
  fi
  if (( ! rc )); then
    _zfc_apply_completion_styles
    rc=$?
    _zfc_finalize_styles
    finalize_rc=$?
    (( rc )) || rc=$finalize_rc
  fi
  (( rc )) || _zfc_configure_optional_runtime || rc=$?

  if (( rc )); then
    zsh-fancy-completions_plugin_unload
    return "$rc"
  fi
  _zfc_loaded=1
} "${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
