# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

typeset repo_dir=${0:A:h:h}
typeset mode=${1:-preconfigured}
typeset -gA Plugins
typeset -gA ZI
typeset -g PMSPEC=
typeset -g TERM=xterm-256color
typeset -g COMPLETION_WAITING_DOTS=1
typeset test_cache=$(mktemp -d "${TMPDIR:-/tmp}/zfc-test-XXXXXX")
trap 'rm -rf "$test_cache"' EXIT
ZI[CACHE_DIR]=$test_cache
autoload -Uz compinit
compinit -i -d "$test_cache/.zcompdump"
setopt err_return no_unset

if [[ $mode == preconfigured ]]; then
  typeset -g ZFC_OS=before-load
  Plugins[ZF_COMPLETIONS]=before-load
  unsetopt complete_in_word
  setopt menu_complete
  zstyle ':completion:*' cache-path before-load
  bindkey -M emacs '^I' expand-or-complete
else
  unset ZFC_OS
  unset 'Plugins[ZF_COMPLETIONS]'
  zstyle -d ':completion:*' cache-path
fi

typeset before_fpath="${(j:\n:)fpath}"
source "$repo_dir/zsh-fancy-completions.plugin.zsh"

[[ $Plugins[ZF_COMPLETIONS] == "$repo_dir" ]]
[[ $ZFC_OS != before-load ]]
[[ -o complete_in_word ]]
[[ ! -o menu_complete ]]
[[ $(zstyle -L ':completion:*' cache-path) != *before-load* ]]

zsh-fancy-completions_plugin_unload

if [[ $mode == preconfigured ]]; then
  [[ $Plugins[ZF_COMPLETIONS] == before-load ]]
  [[ $ZFC_OS == before-load ]]
  [[ ! -o complete_in_word ]]
  [[ -o menu_complete ]]
  [[ $(zstyle -L ':completion:*' cache-path) == *before-load* ]]
else
  (( ! ${+Plugins[ZF_COMPLETIONS]} ))
  (( ! ${+ZFC_OS} ))
  [[ -z $(zstyle -L ':completion:*' cache-path) ]]
fi
[[ "${(j:\n:)fpath}" == "$before_fpath" ]]
[[ $(bindkey -M emacs '^I') == *expand-or-complete ]]
(( ! ${+functions[zsh-fancy-completions_plugin_unload]} ))
[[ -z ${(M)${(k)parameters}:#_zfc_*} ]]

print "unload round trip ok: $mode"
