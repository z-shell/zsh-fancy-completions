# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Verify the ':completion:*:hosts' style follows `Include` directives in
# ~/.ssh/config, so Host aliases defined in included files (e.g. the common
# ~/.ssh/config.d/*.conf layout) are offered for completion and host
# highlighting, not just those written directly in ~/.ssh/config.

typeset repo_dir=${0:A:h:h}
typeset -gA Plugins ZI
typeset -g PMSPEC=
typeset -g TERM=xterm-256color

typeset test_home
test_home=$(mktemp -d "${TMPDIR:-/tmp}/zfc-hosts-XXXXXX")
trap 'rm -rf "$test_home"' EXIT

mkdir -p "$test_home/.ssh/config.d"
cat >"$test_home/.ssh/config" <<'EOF'
Include ~/.ssh/config.d/*.conf

Host direct-host
  HostName 203.0.113.10
EOF
cat >"$test_home/.ssh/config.d/network.conf" <<'EOF'
Host included-host included-alias
  HostName 198.51.100.20
EOF

typeset -g HOME=$test_home

source "$repo_dir/zsh-fancy-completions.plugin.zsh"

# `zstyle -a` on an `-e` style evaluates the code and returns its `reply`.
typeset -a resolved
zstyle -a ':completion:*:hosts' hosts resolved

typeset expected ok=1
for expected in direct-host included-host included-alias; do
  if [[ -z ${resolved[(r)$expected]} ]]; then
    print "MISSING: $expected"
    ok=0
  fi
done

if (( ok )); then
  print "hosts include-follow ok"
else
  print "hosts include-follow FAILED"
  print "resolved: ${resolved}"
  exit 1
fi
