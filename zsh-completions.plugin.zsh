# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Copyright (c) 2022 Salvydas Lukosius
#
# Return if requirements are missing
if [[ $TERM == 'dumb' ]]; then
  return 1
fi

# Zsh Plugin Standard
# https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
typeset -gA Plugins
Plugins[ZSH_COMPLETIONS]="${0:h}"

# https://wiki.zshell.dev/community/zsh_plugin_standard#funtions-directory
if [[ $PMSPEC != *f* ]]; then
  fpath+=( "${0:h}/functions" )
fi

# Zsh's cache directory
[[ -z $ZSH_CACHE_DIR ]] && typeset -gx ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zi"
[[ -d $ZSH_CACHE_DIR ]] || command mkdir -p "$ZSH_CACHE_DIR"

autoload -Uz .os-type .compatibility .options .variables .initialization .styles

.compatibility
.options
.variables
.initialization
.styles
