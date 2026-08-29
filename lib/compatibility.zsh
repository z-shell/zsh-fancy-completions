# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

_zfc_apply_compatibility() {
  builtin emulate -L zsh

  local brew_prefix
  [[ $OSTYPE == darwin* ]] || return 0
  (( ${+commands[brew]} )) || return 0

  brew_prefix=${HOMEBREW_PREFIX:-${HOMEBREW_REPOSITORY:-${commands[brew]:A:h:h}}}
  [[ $brew_prefix == /usr/local/Homebrew ]] && brew_prefix=${brew_prefix:h}
  [[ -d $brew_prefix/opt/curl/share/zsh/site-functions ]] || return 0

  _zfc_add_fpath "$brew_prefix/opt/curl/share/zsh/site-functions" prepend
}
