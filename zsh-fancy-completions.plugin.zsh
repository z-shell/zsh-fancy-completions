# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# Resolve the source path without assigning to special parameter 0.
() {
  builtin emulate -L zsh

  local source_path plugin_dir library name rc=0 finalize_rc=0
  local -a libraries private_functions

  source_path="${${(M)1:#/*}:-$PWD/$1}"
  plugin_dir=${source_path:a:h}

  if (( ${+functions[zfc_plugin_unload]} )); then
    (( ${+parameters[_zfc_loaded]} && _zfc_loaded )) && return 0
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
    unfunction zfc_plugin_unload 2>/dev/null || true
    return "$rc"
  fi

  _zfc_capture_state

  libraries=(compatibility hosts completion widgets doctor)
  for library in "${libraries[@]}"; do
    builtin source "$plugin_dir/lib/$library.zsh" || {
      rc=$?
      break
    }
  done

  if (( ! rc )); then
    _zfc_record_applied_function zfc_manage
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
    zfc_plugin_unload
    return "$rc"
  fi
  _zfc_loaded=1
  private_functions=(
    _zfc_apply_compatibility
    _zfc_apply_completion_styles
    _zfc_apply_core_styles
    _zfc_apply_matching_styles
    _zfc_apply_correction_styles
    _zfc_apply_color_styles
    _zfc_apply_host_styles
    _zfc_apply_cache_styles
    _zfc_apply_process_styles
    _zfc_apply_manpage_styles
    _zfc_configure_optional_runtime
    _zfc_configure_waiting_widget
    _zfc_prepare_configuration
    _zfc_capture_state
    _zfc_finalize_styles
  )
  for name in "${private_functions[@]}"; do
    unfunction "$name" 2>/dev/null || true
  done
} "${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
