# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Description: Tab completion

# Make sure the completion system is initialised
(( ${+_comps} )) || return 1

# Menu completion
autoload -Uz _complete_menu
zle -N _complete_menu

# Manpage comletion
autoload -Uz _man_glob
compctl -K _man_glob -x 'C[-1,-P]' -m - 'R[-*l*,;]' -g '*.(man|[0-9nlpo](|[a-z]))' + -g '*(-/)' -- man

# Tools - host completion for a few commands
compctl -k hosts ftp lftp ncftp ssh w3m lynx links elinks nc telnet rlogin host
compctl -k hosts -P '@' finger

# Case-insensitive (all), partial-word, and then substring completion.
if [[ "$CASE_SENSITIVE" = true ]]; then
  zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
else
  if [[ "$HYPHEN_INSENSITIVE" = true ]]; then
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
  else
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
  fi
fi
unset CASE_SENSITIVE HYPHEN_INSENSITIVE

if [[ ${COMPLETION_WAITING_DOTS:-false} != false ]]; then
  autoload -Uz .expand-or-complete-with-dots
  zle -N .expand-or-complete-with-dots
  bindkey -M emacs "^I" .expand-or-complete-with-dots
  bindkey -M viins "^I" .expand-or-complete-with-dots
  bindkey -M vicmd "^I" .expand-or-complete-with-dots
fi
