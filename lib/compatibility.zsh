# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Description: Compatibility functions

case "$OSTYPE" in
  android*)
    typeset -g OS='android'
    ;;
  darwin*)
    typeset -g OS='darwin'
    ;;
  linux*)
    typeset -g OS='linux'
    ;;
  freebsd*)
    typeset -g OS='freebsd'
    ;;
  netbsd*)
    typeset -g OS='netbsd'
    ;;
  openbsd*)
    typeset -g OS='openbsd'
    ;;
  sunos*)
    typeset -g OS='solaris'
    ;;
  msys* | cygwin* | mingw*)
    typeset -g OS='windows'
    ;;
  nt | win*)
    typeset -g OS='windows'
    ;;
  *)
    typeset -g OS='unknown'
    ;;
esac

if [[ $OS == 'darwin' ]]; then
  # Add completion for keg-only brewed curl on macOS when available.
  if (( $+commands[brew] )); then
    typeset brew_prefix=${HOMEBREW_PREFIX:-${HOMEBREW_REPOSITORY:-$commands[brew]:A:h:h}}
    # $HOMEBREW_PREFIX defaults to $HOMEBREW_REPOSITORY but is explicitly set to
    # /usr/local when $HOMEBREW_REPOSITORY is /usr/local/Homebrew.
    # https://github.com/Homebrew/brew/blob/2a850e02d8f2dedcad7164c2f4b95d340a7200bb/bin/brew#L66-L69
    [[ $brew_prefix == '/usr/local/Homebrew' ]] && brew_prefix=$brew_prefix:h
    
    # Only add to fpath if the directory exists
    [[ -d "$brew_prefix/opt/curl/share/zsh/site-functions" ]] && \
      fpath=($brew_prefix/opt/curl/share/zsh/site-functions $fpath)
    
    unset brew_prefix
  fi
fi
