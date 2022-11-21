#!/usr/bin/env zsh
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
Plugins[ZF_COMP_DIR]="${0:h}"
Plugins[ZF_COMP_COMPATIBILITY]="${0:h}/functions/.tabcompletion"
Plugins[ZF_COMP_TAB_COMP]="${0:h}/functions/.tabcompletion"
Plugins[ZF_COMP_AUTO_COMP]="${0:h}/functions/.autocomplete"

# https://wiki.zshell.dev/community/zsh_plugin_standard#funtions-directory
if [[ $PMSPEC != *f* ]]; then
  fpath+=( "${0:h}/functions" )
fi

if (( AUTO_COMP == 0 )); then 
  source ${Plugins[ZF_COMP_AUTO_COMP]}
fi

if (( TAB_COMP == 0 )); then
  source ${Plugins[ZF_COMP_COMPATIBILITY]}
  source ${Plugins[ZF_COMP_TAB_COMP]}
fi
