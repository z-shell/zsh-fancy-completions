# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Verify the ':completion:*:hosts' style follows `Include` directives in
# ~/.ssh/config, so Host aliases defined in included files (e.g. the common
# ~/.ssh/config.d/*.conf layout) are offered for completion and host
# highlighting, not just those written directly in ~/.ssh/config.
#
# Covers each include-path form OpenSSH accepts:
#   ~/…      tilde-home
#   ~name/…  named form — the same branch as `~user/…`, which a plain
#            `${path/#\~/$HOME}` substitution would mangle into `$HOMEname/…`
#   path     relative, resolved against ~/.ssh
#   "…"      quoted, so paths may contain spaces
# plus transitive includes (an included file including another).

typeset repo_dir=${0:A:h:h}
typeset -gA Plugins ZI
typeset -g PMSPEC=
typeset -g TERM=xterm-256color

typeset test_home
test_home=$(mktemp -d "${TMPDIR:-/tmp}/zfc-hosts-XXXXXX")
trap 'rm -rf "$test_home"' EXIT

mkdir -p "$test_home/.ssh/config.d/nested" "$test_home/extra"

# A named directory exercises the `~name/…` include form hermetically; a real
# `~user/…` would resolve through the password database, outside $test_home.
hash -d zfc_extra="$test_home/extra"

cat >"$test_home/.ssh/config" <<'EOF'
Include ~/.ssh/config.d/*.conf
Include ~zfc_extra/*.conf
Include relative.conf
Include "spaced name.conf"

Host direct-host
  HostName 203.0.113.10
EOF
cat >"$test_home/.ssh/config.d/network.conf" <<'EOF'
Include ~/.ssh/config.d/nested/*.conf

Host included-host included-alias
  HostName 198.51.100.20
EOF
cat >"$test_home/.ssh/config.d/nested/deep.conf" <<'EOF'
Host nested-host
  HostName 198.51.100.30
EOF
cat >"$test_home/extra/named.conf" <<'EOF'
Host named-dir-host
  HostName 198.51.100.40
EOF
cat >"$test_home/.ssh/relative.conf" <<'EOF'
Host relative-host
  HostName 198.51.100.50
EOF
cat >"$test_home/.ssh/spaced name.conf" <<'EOF'
Host spaced-host
  HostName 198.51.100.60
EOF

# An include cycle must terminate rather than loop forever.
print 'Include ~/.ssh/config' >>"$test_home/.ssh/config.d/network.conf"

# Wildcard patterns are configuration, not hosts, and must not be offered.
print -l '' 'Host *' '  ServerAliveInterval 60' >>"$test_home/.ssh/config"

typeset -g HOME=$test_home

source "$repo_dir/zsh-fancy-completions.plugin.zsh"

# `zstyle -a` on an `-e` style evaluates the code and returns its `reply`.
typeset -a resolved
zstyle -a ':completion:*:hosts' hosts resolved

typeset expected ok=1
for expected in direct-host included-host included-alias nested-host \
  named-dir-host relative-host spaced-host; do
  if (( ! ${resolved[(Ie)$expected]} )); then
    print "MISSING: $expected"
    ok=0
  fi
done

if (( ${resolved[(Ie)\*]} )); then
  print "UNEXPECTED: wildcard 'Host *' offered as a host"
  ok=0
fi

if (( ok )); then
  print "hosts include-follow ok"
else
  print "hosts include-follow FAILED"
  print "resolved: ${resolved}"
  exit 1
fi
