#!/usr/bin/env zsh

# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

# ‑‑‑‑‑‑‑‑‑ ⸨ COMPLETION OPTIONS ⸩ ‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑

setopt COMPLETE_IN_WORD       # Complete from both ends of a word.
setopt ALWAYS_TO_END          # Move the cursor to the end of a completed word.
setopt PATH_DIRS              # Perform path search even on command names with slashes.
setopt AUTO_MENU              # Show the completion menu on a successive tab press.
setopt AUTO_LIST              # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH       # If the completed parameter is a directory, add a trailing slash.
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
setopt EXTENDED_GLOB          # Needed for file modification glob modifiers with compinit.
unsetopt MENU_COMPLETE        # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL         # Disable start/stop characters in shell editor.

# ‑‑‑‑‑‑‑‑‑ ⸨ COMPLETION CONFIGURATION ⸩ ‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑

# Enable cache - Some functions, like _apt and _dpkg, are very slow.
# You can use a cache to proxy the list of results (like the list of available Debian packages)
typeset cache_dir="${ZI[CACHE_DIR]:-${XDG_CACHE_HOME:-${ZDOTDIR:-$HOME/.cache}}/zi}"
if [[ ! -d "$cache_dir" ]]; then
  if ! mkdir -p "$cache_dir" 2>/dev/null; then
    # Fallback to a temporary directory if cache creation fails
    cache_dir=$(mktemp -d "${TMPDIR:-/tmp}/zsh-completion-cache-XXXXXX" 2>/dev/null)
    if [[ -z "$cache_dir" || ! -d "$cache_dir" ]]; then
      cache_dir="${TMPDIR:-/tmp}/zsh-completion-cache-$$-$RANDOM"
      mkdir -p "$cache_dir" 2>/dev/null || cache_dir=""
    fi
  fi
fi

zstyle ':completion:*' cache-path "$cache_dir"
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' file-sort name

# Enable rehash on completion so new installed programs are found automatically:
zstyle ':completion:*' rehash true

# How many completions switch on menu selection
zstyle ':completion:*' menu select=long

# If there are more than 5 options, allow selecting from a menu with arrows (case insensitive completion!).
zstyle ':completion:*-case' menu select=5

autoload -Uz .force_rehash
zstyle ':completion:*'  completer _expand .force_rehash _complete _ignored _correct _approximate _files

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}»» %d (errors: %e) ««%f'
zstyle ':completion:*:descriptions' format ' %F{cyan}»» %d ««%f'
zstyle ':completion:*:messages' format ' %F{purple} »» %d ««%f'
zstyle ':completion:*:warnings' format ' %F{red}»» no matches found ««%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}»» %d ««%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Enable history menu selection
zstyle ':completion:*:history-words'	menu yes

# Enable expand completer for all expansions
zstyle ':completion:*:expand:*'		tag-order all-expansions

# Enable offering indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*'	tag-order indexes parameters

# Enable matches to separate into groups
zstyle ':completion:*:matches' group 'yes'

# Enable processes completion for all user processes
zstyle ':completion:*:processes'  command 'ps -au$USER'

# Adjust color-completion style
zstyle ':completion:*:default'  list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*'  list-colors  'reply=( "=(#b)(*$PREFIX)(?)*=00=$color[green]=$color[bg-green]" )'

# Adjust case-insensitive completions for: (all),partial-word and then substring matches
zstyle ':completion:*' 	matcher-list 'm:ss=ß m:ue=ü m:ue=Ü m:oe=ö m:oe=Ö m:ae=ä m:ae=Ä m:{a-zA-Zöäüa-zÖÄÜ}={A-Za-zÖÄÜA-Zöäü}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Adjust mismatch handling - allow one error for every three characters typed in approximate completer
# Ensure to cap (at 7) the max-errors to avoid hanging.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# Adjust selection prompt style
zstyle ':completion:*'  select-prompt %SScrolling active: current selection at %P Lines: %m

# Fuzzy match mistyped completions.
zstyle ':completion:*:match:*' original only

# Adjust completion to offer fish-style highlighting for extra-verbose command completion:
zstyle -e ':completion:*:-command-:*:commands'	list-colors 'reply=( '\''=(#b)('\''$words[CURRENT]'\''|)*-- #(*)=0=38;5;45=38;5;136'\'' '\''=(#b)('\''$words[CURRENT]'\''|)*=0=38;5;45'\'' )'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
# Enable completion of 'cd -<tab>' and 'cd -<ctrl-d>' with menu
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environmental Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:(killall|pkill|kill):*' menu yes select
zstyle ':completion:*:*:(killall|pkill|kill):*' force-list always
zstyle ':completion:*:*:(killall|pkill|kill):*' insert-ids single

# Complete manual by their section
zstyle ':completion:*:manuals'  separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'  menu yes select

# Media Players
zstyle ':completion:*:*:mpg123:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mocp:*' file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'

# Mutt
if [[ -r "$HOME/.mutt/aliases" ]]; then
  zstyle ':completion:*:*:mutt:*' menu yes select
  zstyle ':completion:*:mutt:*' users ${${${(f)"$(<"$HOME/.mutt/aliases")"}#alias[[:space:]]}%%[[:space:]]*}
fi

# Populate hostname completion.
# Version that collects hostnames and handles missing files gracefully
zstyle -e ':completion:*:hosts' hosts '
  typeset -a _hosts
  typeset -a _ssh_hosts _etc_hosts _ssh_config_hosts
  
  # SSH known hosts (only if files exist)
  [[ -r /etc/ssh_known_hosts ]] && \
    _ssh_hosts+=(${=${=${=${${(f)"$(<"/etc/ssh_known_hosts")"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ })
  [[ -r $HOME/.ssh/known_hosts ]] && \
    _ssh_hosts+=(${=${=${=${${(f)"$(<"$HOME/.ssh/known_hosts")"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ })
  [[ -r /etc/ssh_known_hosts2 ]] && \
    _ssh_hosts+=(${=${=${=${${(f)"$(<"/etc/ssh_known_hosts2")"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ })
  [[ -r $HOME/.ssh/known_hosts2 ]] && \
    _ssh_hosts+=(${=${=${=${${(f)"$(<"$HOME/.ssh/known_hosts2")"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ })
  
  # /etc/hosts (only if readable)
  [[ -r /etc/hosts ]] && \
    _etc_hosts=(${=${(f)"$(<"/etc/hosts")"}%%\#*})
  
  # SSH config hosts (only if file exists)
  [[ -r $HOME/.ssh/config ]] && \
    _ssh_config_hosts=(${=${${${${(@M)${(f)"$(<"$HOME/.ssh/config")"}:#Host *}#Host }:#*\**}:#*\?*}})
  
  _hosts=($_ssh_hosts $_etc_hosts $_ssh_config_hosts)
  reply=($_hosts)
'

# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Case-insensitive (all), partial-word, and then substring completion.
# Note: The matcher-list is already set above with German umlauts support (line 77)
# This provides case-insensitive completion as the default behavior

# ‑‑‑‑‑‑‑‑‑ ⸨ DISABLE / IGNORE ⸩ ‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑‑

# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# Disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Don't complete not-required/available users/commands
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|TRAP*)'
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'
zstyle '*' single-ignored show

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Prevent CVS files/directories from being completed
zstyle ':completion:*:(all-|)files'	ignored-patterns '(|*/)CVS'
zstyle ':completion:*:cd:*'		ignored-patterns '(*/)#CVS'

# Prevent commands like `rm'
zstyle ':completion:*:rm:*'		ignore-line yes

# Prevent menu completion for ambiguous initial strings
zstyle ':completion:*'  insert-unambiguous true
zstyle ':completion:*:corrections'	format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*:correct:*'	original true

# Prevent completion of functions for commands you don't have
zstyle ':completion:*:functions'	ignored-patterns '(_*|pre(cmd|exec))'

# Prevent files to be ignored from zcompile
zstyle ':completion:*:*:zcompile:*'	ignored-patterns '(*~|*.zwc)'
zstyle ':completion:correct:'		prompt 'correct to: %e'

#Prevent comp to glob the first part of the path to avoid partial globs. (Performance)
zstyle ':completion:*' accept-exact '*(N)'

# Prevent trailing slash if argument is a directory
zstyle ':completion:*'			squeeze-slashes true
zstyle ':completion::complete:*' '\\'

# Prevent completion of backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

# Prevent these filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns  '*?.(o|c~|old|pro|zwc)' '*~'

# Prevent rm completion
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Load the zsh/complist module for menu-select widget.
zmodload -i zsh/complist

# Make sure the completion system is initialized
# Use the cache directory we set up earlier for the dump file
typeset zcompdump_path="${cache_dir}/.zcompdump"
(( ${+_comps} )) || autoload -U compinit && compinit -d "$zcompdump_path"

# Load colors for completion
autoload -U colors && colors

# Compatibility with bash’s programmable completion system.
# Defines the functions, compgen and complete which correspond to the bash builtin with the same names.
autoload -U +X bashcompinit && bashcompinit

# Menu completion
autoload -Uz .complete_menu
zle -N .complete_menu

# Manpage completion
# Check if the variable is set and non-zero
if (( ${MANPAGE_COMPLETION:-0} )); then
  autoload -Uz .man_glob
  compctl -K .man_glob -x 'C[-1,-P]' -m - 'R[-*l*,;]' -g '*.(man|[0-9nlpo](|[a-z]))' + -g '*(-/)' -- man
fi

# Host completion for a few commands.
compctl -k hosts ftp lftp ncftp ssh w3m lynx links elinks nc telnet rlogin host
compctl -k hosts -P '@' finger

# Completion waiting dots (for slow completions).
# Check if the variable is set and non-zero
if (( ${COMPLETION_WAITING_DOTS:-0} )); then
  autoload -Uz .expand-or-complete-with-dots
  zle -N .expand-or-complete-with-dots

  bindkey -M emacs "^I" .expand-or-complete-with-dots
  bindkey -M viins "^I" .expand-or-complete-with-dots
  bindkey -M vicmd "^I" .expand-or-complete-with-dots
fi

# Clean up local variables
unset cache_dir zcompdump_path
