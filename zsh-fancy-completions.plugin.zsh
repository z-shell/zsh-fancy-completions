# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# Preserve caller state while resolving this sourced entrypoint.
() {
  # The plugin intentionally updates caller options and restores them on unload.
  # Keep those effects outside the localized source-path resolver.
  unsetopt localoptions

  typeset source_path plugin_dir
  () {
    builtin emulate -L zsh

    source_path="${${(M)1:#/*}:-$PWD/$1}"
    plugin_dir=${source_path:h}
  } "$1"
  typeset -r source_path plugin_dir

# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
typeset -gA Plugins
source "${plugin_dir}/lib/state.zsh"
_zfc_capture_state
Plugins[ZF_COMPLETIONS]="$plugin_dir"

# https://wiki.zshell.dev/community/zsh_plugin_standard#funtions-directory
if [[ $PMSPEC != *f* ]]; then
  _zfc_add_fpath "${plugin_dir}/functions"
fi

# Return if requirements are missing
if [[ $TERM == 'dumb' ]]; then
  return 0
else
  source "${plugin_dir}/lib/compatibility.zsh"
  {
    alias zstyle=_zfc_zstyle
    source "${plugin_dir}/lib/completion.zsh"
  } always {
    unalias zstyle
  }
fi
} "${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
