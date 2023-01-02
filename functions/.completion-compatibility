# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Description: Compatibility functions

case "$OSTYPE" in
  android*)
    typeset OS='android'
    ;;
  darwin*)
    typeset OS='darwin'
    ;;
  linux*)
    typeset OS='linux'
    ;;
  freebsd*)
    typeset OS='freebsd'
    ;;
  netbsd*)
    typeset OS='netbsd'
    ;;
  openbsd*)
    typeset OS='openbsd'
    ;;
  sunos*)
    typeset OS='solaris'
    ;;
  msys* | cygwin* | mingw*)
    typeset OS='windows'
    ;;
  nt | win*)
    typeset OS='windows'
    ;;
  *)
    typeset OS='unknown'
    ;;
esac

if [[ $OS == 'darwin' ]]; then
  # Add completion for keg-only brewed curl on macOS when available.
  if (( $+commands[brew] )); then
    brew_prefix=${HOMEBREW_PREFIX:-${HOMEBREW_REPOSITORY:-$commands[brew]:A:h:h}}
    # $HOMEBREW_PREFIX defaults to $HOMEBREW_REPOSITORY but is explicitly set to
    # /usr/local when $HOMEBREW_REPOSITORY is /usr/local/Homebrew.
    # https://github.com/Homebrew/brew/blob/2a850e02d8f2dedcad7164c2f4b95d340a7200bb/bin/brew#L66-L69
    [[ $brew_prefix == '/usr/local/Homebrew' ]] && brew_prefix=$brew_prefix:h
    fpath=($brew_prefix/opt/curl/share/zsh/site-functions(/N) $fpath)
    unset brew_prefix
  fi
fi
