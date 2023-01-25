# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Description: Tab completion

# Menu completion
autoload -Uz _complete_menu
zle -C complete-menu menu-select _generic
zle -N _complete_menu

# Use ls-colors for path completions
autoload -Uz _set-list-colors
sched 0 _set-list-colors

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
