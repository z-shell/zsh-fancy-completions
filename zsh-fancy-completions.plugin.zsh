# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
typeset -gA Plugins
source "${0:h}/lib/state.zsh"
_zfc_capture_state
Plugins[ZF_COMPLETIONS]="${0:h}"

# https://wiki.zshell.dev/community/zsh_plugin_standard#funtions-directory
if [[ $PMSPEC != *f* ]]; then
  _zfc_add_fpath "${0:h}/functions"
fi

# Return if requirements are missing
if [[ $TERM == 'dumb' ]]; then
  return 0
else
  source "${0:h}/lib/compatibility.zsh"
  {
    alias zstyle=_zfc_zstyle
    source "${0:h}/lib/completion.zsh"
  } always {
    unalias zstyle
  }
fi
