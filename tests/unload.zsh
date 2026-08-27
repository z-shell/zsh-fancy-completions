# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

typeset repo_dir=${0:A:h:h}

# Both modes matter: `preconfigured` proves prior user settings are restored,
# `clean` proves nothing is left behind when there was nothing to restore.
# With no argument, run each in a fresh shell so a bare `zsh tests/unload.zsh`
# is the whole contract — that is how CI invokes every tests/*.zsh.
if (( ! $# )); then
  for mode in preconfigured clean; do
    # -f keeps the nested run hermetic: without it a user's ~/.zshenv can set
    # options this test asserts on. $? rather than a literal so a mode's real
    # exit status reaches CI instead of a flattened 1.
    zsh -f "${0:A}" "$mode" || exit $?
  done
  exit 0
fi

typeset mode=$1
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
typeset -g LS_COLORS=${LS_COLORS-}
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
