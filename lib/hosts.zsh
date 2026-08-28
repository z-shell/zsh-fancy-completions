# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

_zfc_ensure_stat_module() {
  builtin emulate -L zsh

  if ! zmodload -e zsh/stat; then
    zmodload zsh/stat || return
    _zfc_owned_modules[zsh/stat]=1
  fi
}

_zfc_host_signature_for() {
  builtin emulate -L zsh

  local path
  local -A info
  local -a parts

  _zfc_ensure_stat_module || return
  for path in "$@"; do
    info=()
    if zstat -H info -- "$path" 2>/dev/null; then
      parts+=("${path}:${info[mtime]}:${info[size]}:${info[inode]}")
    else
      parts+=("${path}:-")
    fi
  done
  REPLY="${(j:$'\x1e':)parts}"
}

_zfc_add_host_candidate() {
  builtin emulate -L zsh

  local candidate=$1
  [[ -n $candidate ]] || return 0
  [[ $candidate == '!'* || $candidate == '|'* ]] && return 0
  [[ $candidate == *'*'* || $candidate == *'?'* ]] && return 0
  (( ${_zfc_host_cache[(Ie)$candidate]} )) || _zfc_host_cache+=("$candidate")
}

_zfc_read_known_hosts() {
  builtin emulate -L zsh

  local file=$1 line field candidate
  local -a words candidates
  [[ -r $file ]] || return 0

  for line in "${(@f)$(<"$file")}"; do
    [[ -n $line && $line != '#'* ]] || continue
    words=(${=line})
    (( $#words )) || continue
    field=$words[1]
    [[ $field == '@'* ]] && field=${words[2]-}
    candidates=("${(@s:,:)field}")
    for candidate in "${candidates[@]}"; do
      if [[ $candidate == '['*']:'* ]]; then
        candidate=${candidate#\[}
        candidate=${candidate%%\]:*}
      fi
      _zfc_add_host_candidate "$candidate"
    done
  done
}

_zfc_read_etc_hosts() {
  builtin emulate -L zsh

  local file=$1 line candidate
  local -a words
  [[ -r $file ]] || return 0

  for line in "${(@f)$(<"$file")}"; do
    line=${line%%\#*}
    words=(${=line})
    (( $#words > 1 )) || continue
    for candidate in "${words[@]:1}"; do
      _zfc_add_host_candidate "$candidate"
    done
  done
}

_zfc_watch_include_parent() {
  builtin emulate -L zsh

  local path=$1 parent=${1:h}
  while [[ $parent != / ]] &&
    [[ $parent == *\** || $parent == *\?* || $parent == *\[* ]]; do
    parent=${parent:h}
  done
  [[ -n $parent ]] || parent=/
  (( ${_zfc_host_watch_dirs[(Ie)$parent]} )) || _zfc_host_watch_dirs+=("$parent")
}

_zfc_expand_include() {
  builtin emulate -L zsh
  setopt extended_glob

  local raw=$1 path quoted=0 match
  local -a matches

  [[ ${raw[1]-} == '"' || ${raw[1]-} == "'" ]] && quoted=1
  path=${(Q)raw}
  if [[ $path == '~/'* ]]; then
    path=$HOME/${path#\~/}
  elif [[ $path == '~'* ]]; then
    matches=(${~path}(N-.))
    path=${matches[1]-$path}
  elif [[ $path != /* ]]; then
    path=$HOME/.ssh/$path
  fi

  _zfc_watch_include_parent "$path"
  if (( quoted )); then
    (( ${_zfc_host_sources[(Ie)$path]} )) || _zfc_host_sources+=("$path")
    [[ -f $path && -r $path ]] && reply+=("$path")
    return 0
  fi

  matches=(${~path}(N-.))
  if (( ! $#matches )); then
    (( ${_zfc_host_sources[(Ie)$path]} )) || _zfc_host_sources+=("$path")
  fi
  for match in "${matches[@]}"; do
    (( ${_zfc_host_sources[(Ie)$match]} )) || _zfc_host_sources+=("$match")
    [[ -r $match ]] && reply+=("$match")
  done
}

_zfc_read_ssh_config() {
  builtin emulate -L zsh
  setopt extended_glob

  local file line trimmed keyword rest raw candidate
  local -a queue lines tokens reply
  local -A seen

  queue=("$HOME/.ssh/config")
  while (( $#queue )); do
    file=$queue[1]
    shift queue
    (( ${_zfc_host_sources[(Ie)$file]} )) || _zfc_host_sources+=("$file")
    [[ -f $file && -r $file ]] || continue
    (( ${+seen[$file]} )) && continue
    seen[$file]=1

    lines=("${(@f)$(<"$file")}")
    for line in "${lines[@]}"; do
      trimmed=${line##[[:space:]]#}
      [[ -n $trimmed && $trimmed != '#'* ]] || continue
      keyword=${trimmed%%[[:space:]]*}
      rest=${trimmed#"$keyword"}
      rest=${rest##[[:space:]]#}

      case ${(L)keyword} in
        host)
          tokens=(${(z)rest})
          for raw in "${tokens[@]}"; do
            candidate=${(Q)raw}
            _zfc_add_host_candidate "$candidate"
          done
          ;;
        include)
          tokens=(${(z)rest})
          for raw in "${tokens[@]}"; do
            reply=()
            _zfc_expand_include "$raw"
            queue+=("${reply[@]}")
          done
          ;;
        match)
          # Match blocks describe conditional configuration, not stable aliases.
          ;;
      esac
    done
  done
}

_zfc_resolve_hosts() {
  builtin emulate -L zsh

  local signature source
  local -a fixed_sources signature_paths

  if [[ $_zfc_host_cache_home == $HOME && -n $_zfc_host_signature ]]; then
    signature_paths=("${_zfc_host_sources[@]}" "${_zfc_host_watch_dirs[@]}")
    _zfc_host_signature_for "${signature_paths[@]}" || return
    [[ $REPLY == $_zfc_host_signature ]] && return 0
  fi

  _zfc_host_cache=()
  _zfc_host_sources=()
  _zfc_host_watch_dirs=()
  fixed_sources=(
    /etc/ssh_known_hosts
    /etc/ssh_known_hosts2
    /etc/ssh/ssh_known_hosts
    /etc/ssh/ssh_known_hosts2
    "$HOME/.ssh/known_hosts"
    "$HOME/.ssh/known_hosts2"
    /etc/hosts
  )
  _zfc_host_sources+=("${fixed_sources[@]}")

  for source in "${fixed_sources[@]:0:6}"; do
    _zfc_read_known_hosts "$source"
  done
  _zfc_read_etc_hosts /etc/hosts
  _zfc_read_ssh_config

  signature_paths=("${_zfc_host_sources[@]}" "${_zfc_host_watch_dirs[@]}")
  _zfc_host_signature_for "${signature_paths[@]}" || return
  _zfc_host_signature=$REPLY
  _zfc_host_cache_home=$HOME
}

_zfc_refresh_hosts() {
  builtin emulate -L zsh

  _zfc_host_cache=()
  _zfc_host_sources=()
  _zfc_host_watch_dirs=()
  _zfc_host_signature=''
  _zfc_host_cache_home=''
}
