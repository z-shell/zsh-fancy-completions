# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

_zfc_apply_core_styles() {
  builtin emulate -L zsh

  _zfc_style ':completion:*' accept-exact '*(N)'
  _zfc_style ':completion:*' file-sort name
  _zfc_style ':completion:*' rehash true
  _zfc_style ':completion:*' menu select=long
  _zfc_style ':completion:*:*:*:*:*' menu select
  _zfc_style ':completion:*:options' description yes
  _zfc_style ':completion:*:options' auto-description '%d'
  _zfc_style ':completion:*:descriptions' format ' %F{cyan}>> %d%f'
  _zfc_style ':completion:*:messages' format ' %F{magenta}>> %d%f'
  _zfc_style ':completion:*:warnings' format ' %F{red}>> no matches found%f'
  _zfc_style ':completion:*:default' list-prompt '%S%M matches%s'
  _zfc_style ':completion:*' group-name ''
  _zfc_style ':completion:*' verbose yes
  _zfc_style ':completion:*' select-prompt '%SScrolling: %P, line %m%s'
  _zfc_style ':completion:*' special-dirs true
  _zfc_style ':completion:*' squeeze-slashes true
  _zfc_style ':completion:*' insert-unambiguous true

  _zfc_style ':completion:*:history-words' stop yes
  _zfc_style ':completion:*:history-words' remove-all-dups yes
  _zfc_style ':completion:*:history-words' list false
  _zfc_style ':completion:*:history-words' menu yes
  _zfc_style ':completion:*:expand:*' tag-order all-expansions
  _zfc_style ':completion:*:*:-subscript-:*' tag-order indexes parameters
  _zfc_style ':completion:*:matches' group yes

  _zfc_style ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
  _zfc_style ':completion:*:*:cd:*:directory-stack' menu yes select
  _zfc_style ':completion:*:-tilde-:*' group-order named-directories path-directories users expand

  _zfc_style ':completion:*:git-checkout:*' sort false
  _zfc_style ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|TRAP*)'
  _zfc_style ':completion:*:(rm|kill|diff):*' ignore-line other
  _zfc_style ':completion:*:rm:*' file-patterns '*:all-files'
  _zfc_style ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
  _zfc_style ':completion:*:cd:*' ignored-patterns '(*/)#CVS'
  _zfc_style ':completion:*:rm:*' ignore-line yes
  _zfc_style ':completion:*:*:zcompile:*' ignored-patterns '(*~|*.zwc)'
  _zfc_style ':completion:correct:' prompt 'correct to: %e'
  _zfc_style ':completion:*:complete:-command-::commands' ignored-patterns '*\~'
  _zfc_style ':completion:*:*:(^rm):*:*files' ignored-patterns \
    '*?.(o|c~|old|pro|zwc)' '*~'

  _zfc_style ':completion:*:*:mpg123:*' file-patterns \
    '*.(mp3|MP3):audio files *(-/):directories'
  _zfc_style ':completion:*:*:mpg321:*' file-patterns \
    '*.(mp3|MP3):audio files *(-/):directories'
  _zfc_style ':completion:*:*:ogg123:*' file-patterns \
    '*.(ogg|OGG|flac):audio files *(-/):directories'
  _zfc_style ':completion:*:*:mocp:*' file-patterns \
    '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):audio files *(-/):directories'
}

_zfc_apply_matching_styles() {
  builtin emulate -L zsh

  _zfc_style ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'
  _zfc_style ':completion:*:match:*' original only
}

_zfc_apply_correction_styles() {
  builtin emulate -L zsh

  _zfc_style ':completion:*' completer _expand _complete _ignored _correct _approximate _files
  _zfc_style ':completion:*:corrections' format ' %F{green}>> %d (errors: %e)%f'
  _zfc_style -e ':completion:*:approximate:*' max-errors \
    'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'
  _zfc_style ':completion:*:correct:*' original true
}

_zfc_apply_color_styles() {
  builtin emulate -L zsh

  local -a list_colors
  list_colors=("${(@s.:.)${LS_COLORS-}}")
  (( $#list_colors )) && _zfc_style ':completion:*:default' list-colors "${list_colors[@]}"
  _zfc_style -e ':completion:*' list-colors \
    'reply=( "=(#b)(*$PREFIX)(?)*=00=32=42" )'
  _zfc_style -e ':completion:*:-command-:*:commands' list-colors \
    'reply=( "=(#b)($words[CURRENT]|)*-- #(*)=0=38;5;45=38;5;136" "=(#b)($words[CURRENT]|)*=0=38;5;45" )'
  _zfc_style ':completion:*:*:kill:*:processes' list-colors \
    '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
}

_zfc_apply_host_styles() {
  builtin emulate -L zsh

  _zfc_style -e ':completion:*:hosts' hosts \
    '_zfc_resolve_hosts || reply=(); reply=("${_zfc_host_cache[@]}")'
  _zfc_style ':completion:*:(scp|rsync):*' tag-order \
    'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip address *'
  _zfc_style ':completion:*:(scp|rsync):*' group-order \
    users files all-files hosts-domain hosts-host hosts-ipaddr
  _zfc_style ':completion:*:ssh:*' tag-order \
    'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip address *'
  _zfc_style ':completion:*:ssh:*' group-order \
    users hosts-domain hosts-host hosts-ipaddr
  _zfc_style ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns \
    '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
  _zfc_style ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns \
    '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
  _zfc_style ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns \
    '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' \
    '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'
}

_zfc_apply_cache_styles() {
  builtin emulate -L zsh

  _zfc_style ':completion:*' cache-path "$_zfc_cache_dir"
  _zfc_style ':completion:*' use-cache on
}

_zfc_apply_process_styles() {
  builtin emulate -L zsh

  _zfc_style ':completion:*:processes' command 'ps -u $USER -o pid,user,comm -w'
  _zfc_style ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
  _zfc_style ':completion:*:*:(killall|pkill|kill):*' menu yes select
  _zfc_style ':completion:*:*:(killall|pkill|kill):*' force-list always
  _zfc_style ':completion:*:*:(killall|pkill|kill):*' insert-ids single
}

_zfc_apply_manpage_styles() {
  builtin emulate -L zsh

  _zfc_style ':completion:*:manuals' separate-sections true
  _zfc_style ':completion:*:manuals.*' insert-sections true
  _zfc_style ':completion:*:man:*' menu yes select
}

_zfc_apply_completion_styles() {
  builtin emulate -L zsh

  _zfc_feature_enabled core && _zfc_apply_core_styles
  _zfc_feature_enabled matching && _zfc_apply_matching_styles
  _zfc_feature_enabled corrections && _zfc_apply_correction_styles
  _zfc_feature_enabled colors && _zfc_apply_color_styles
  _zfc_feature_enabled hosts && _zfc_apply_host_styles
  _zfc_feature_enabled cache && _zfc_apply_cache_styles
  _zfc_feature_enabled processes && _zfc_apply_process_styles
  _zfc_feature_enabled manpages && _zfc_apply_manpage_styles
  return 0
}
