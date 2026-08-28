# zsh-fancy-completions

`zsh-fancy-completions` supplies completion styles, matching rules, host
discovery, process completion, optional editor feedback, and diagnostics. It is
a standard, plugin-manager-neutral Zsh plugin.

The plugin configures completion. It does not run `compinit`, download data,
create cache directories, or invoke external commands while it is loaded.

## Requirements

- Zsh 5.9.2 or newer
- The native Zsh completion system

## Installation

### Zi

```zsh
zi light z-shell/zsh-fancy-completions
```

Zi remains the canonical plugin manager for the z-shell ecosystem, but no Zi
API is required at runtime.

### Another plugin manager

Load `z-shell/zsh-fancy-completions` as a normal Zsh plugin. The standard entry
point is `zsh-fancy-completions.plugin.zsh`.

### Direct source

```zsh
source /path/to/zsh-fancy-completions/zsh-fancy-completions.plugin.zsh
```

## Initialization order

Add every directory that contains completion functions to `fpath` before
running `compinit`. This plugin may be sourced before or after `compinit`, but it
never initializes completion on the user's behalf.

```zsh
# 1. Add completion function directories to fpath.
fpath=(/path/to/site-functions $fpath)

# 2. Load completion configuration.
source /path/to/zsh-fancy-completions/zsh-fancy-completions.plugin.zsh

# 3. Initialize the native completion system once.
autoload -Uz compinit
compinit

# 4. Only when the bash-compat feature is selected before compinit:
zfc enable bash
```

Plugin managers that own completion initialization should keep owning it. Do
not add a second `compinit` call for this plugin.

## Profiles

Set `ZFC_PROFILE` before loading the plugin. The default is `balanced`.

| Profile    | Features                                                        | Intended use                                                    |
| ---------- | --------------------------------------------------------------- | --------------------------------------------------------------- |
| `minimal`  | `core`                                                          | Predictable menus and grouping with the smallest policy surface |
| `balanced` | `core matching corrections colors hosts cache processes legacy` | General interactive use                                         |
| `full`     | Balanced features plus `manpages bash-compat waiting-dots`      | Every supported integration                                     |

Example:

```zsh
typeset -g ZFC_PROFILE=minimal
zi light z-shell/zsh-fancy-completions
```

## Feature override

Defining `ZFC_FEATURES` replaces the selected profile's feature list. Unknown
feature names fail the load before completion state is changed.

```zsh
typeset -ga ZFC_FEATURES=(core matching colors hosts)
source /path/to/zsh-fancy-completions/zsh-fancy-completions.plugin.zsh
```

Available features are:

| Feature        | Behavior                                                              |
| -------------- | --------------------------------------------------------------------- |
| `core`         | Menus, groups, history, directory, file, and command styles           |
| `matching`     | Case-insensitive, partial-word, and substring matching                |
| `corrections`  | Correct and approximate completers, capped at seven errors            |
| `colors`       | Completion-list and process coloring without loading `colors`         |
| `hosts`        | Cached host aliases from hosts, known-hosts, and OpenSSH config files |
| `cache`        | Native completion cache styles using a project-owned XDG path         |
| `processes`    | Process listing and kill-command styles                               |
| `manpages`     | Native `_man` section and menu styles                                 |
| `bash-compat`  | `bashcompinit` compatibility, only after `compinit` exists            |
| `waiting-dots` | Interactive Tab widget that displays `...` during completion          |
| `legacy`       | Maps the former opt-in variables described below                      |

An explicitly defined empty `ZFC_FEATURES` array applies no features.

## Cache behavior

The default cache path is:

```text
${XDG_CACHE_HOME:-${ZDOTDIR:-$HOME/.cache}}/zsh-fancy-completions
```

Override it before load with `ZFC_CACHE_DIR`. Loading only records the native
completion style, so the directory is created lazily by the completion system
or explicitly with:

```zsh
zfc prepare-cache
```

Host discovery uses an in-memory cache. It is invalidated when a contributing
file or watched include directory changes. Force a refresh with:

```zsh
zfc refresh hosts
```

Host resolution recognizes case-insensitive and indented `Host` and `Include`
directives, follows include cycles safely, treats quoted include paths
literally, and excludes wildcard and negated host patterns. `Match` conditions
are intentionally not treated as stable host aliases.

## Diagnostics

Run the read-only doctor before or after `compinit`:

```zsh
zfc doctor
```

It reports the active profile and features, completion initialization, cache
writability, `compaudit` findings, changed styles, widget and key-binding
conflicts, Bash compatibility state, and lazy module state. It returns non-zero
only for actionable errors such as an insecure `fpath` or an unwritable cache
parent.

Other commands:

```zsh
zfc features
zfc cache-path
zfc enable bash
zfc --help
```

## Compatibility variables

The `legacy` feature recognizes these pre-load variables:

| Variable                    | Equivalent feature |
| --------------------------- | ------------------ |
| `COMPLETION_WAITING_DOTS=1` | `waiting-dots`     |
| `MANPAGE_COMPLETION=1`      | `manpages`         |

New configurations should select features or a profile directly.

## Unload contract

```zsh
zsh-fancy-completions_plugin_unload
```

Repeated sourcing is a no-op. Unload restores styles, public functions,
widgets, bindings, modules, metadata, and `fpath` entries owned by the first
successful load. If a user changes one of those values after load, unload
leaves the newer user value intact.

The plugin does not change shell options and no longer installs legacy
`compctl` definitions or generic dot-prefixed helper functions.

## Development

Run native syntax checks and the ZUnit suite:

```zsh
zsh -n zsh-fancy-completions.plugin.zsh lib/*.zsh tests/cases/*.zsh tests/bench-hosts.zsh
zunit --tap tests/*.zunit
```

The host benchmark is observational and is not a merge gate:

```zsh
tests/bench-hosts.zsh
ZFC_BENCH_ITERATIONS=50 tests/bench-hosts.zsh
```

## License

GPL-3.0. See [LICENSE](LICENSE).
