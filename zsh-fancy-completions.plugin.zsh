# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Require Zsh >= 5.0.0
autoload -Uz is-at-least
if ! is-at-least 5.0.0; then
  print -u2 "zsh-fancy-completions: requires Zsh >= 5.0.0 (running $ZSH_VERSION)"
  return 1
fi

# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
typeset -gA Plugins
Plugins[ZF_COMPLETIONS]="${0:h}"

# https://wiki.zshell.dev/community/zsh_plugin_standard#funtions-directory
if [[ $PMSPEC != *f* ]]; then
  fpath+=( "${0:h}/functions" )
fi

# Return if requirements are missing
if [[ $TERM == 'dumb' ]]; then
  return 0
else
  source "${0:h}/lib/compatibility.zsh"
  source "${0:h}/lib/completion.zsh"
fi

# https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
zsh-fancy-completions_plugin_unload() {
  # Remove functions directory from fpath
  fpath=("${fpath[@]:#${Plugins[ZF_COMPLETIONS]}/functions}")

  # Remove custom zle widgets
  zle -D .complete_menu 2>/dev/null
  zle -D .expand-or-complete-with-dots 2>/dev/null

  # Restore original shell options
  unsetopt COMPLETE_IN_WORD ALWAYS_TO_END PATH_DIRS AUTO_MENU AUTO_LIST \
    AUTO_PARAM_SLASH HIST_EXPIRE_DUPS_FIRST EXTENDED_GLOB
  setopt MENU_COMPLETE FLOW_CONTROL

  # Clean up global variables
  unset 'Plugins[ZF_COMPLETIONS]' ZFC_OS

  # Self-destruct
  unfunction zsh-fancy-completions_plugin_unload
}
