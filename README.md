# zsh-fancy-completions

`zsh-fancy-completions` supplies completion styles, matching rules, host
discovery, process completion, optional editor feedback, and diagnostics. It is
a standard, plugin-manager-neutral Zsh plugin.

The plugin configures completion. It does not run `compinit`, download data,
create cache directories, or invoke external commands while it is loaded.

## Portable shell contract

- Project identifier: `zfc`
- Authoritative entrypoint: `zsh-fancy-completions.plugin.zsh`
- Public configuration context: `:zfc:config`
- Public command: `zfc_manage`
- Unload function: `zfc_plugin_unload`
- `lib/`: private eagerly sourced implementation

The plugin has no portable dependency on a manager-owned registry and does not
create shared `Plugins` state.

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
zfc_manage enable bash
```

Plugin managers that own completion initialization should keep owning it. Do
not add a second `compinit` call for this plugin.

## Profiles

Set the `profile` property before loading the plugin. The default is
`balanced`.

| Profile    | Features                                                   | Intended use                                                    |
| ---------- | ---------------------------------------------------------- | --------------------------------------------------------------- |
| `minimal`  | `core`                                                     | Predictable menus and grouping with the smallest policy surface |
| `balanced` | `core matching corrections colors hosts cache processes`   | General interactive use                                         |
| `full`     | Balanced features plus `manpages bash-compat waiting-dots` | Every supported integration                                     |

Example:

```zsh
zstyle ':zfc:config' profile minimal
zi light z-shell/zsh-fancy-completions
```

## Feature override

Defining the `features` style replaces the selected profile's feature list.
Unknown feature names fail the load before completion state is changed.

```zsh
zstyle ':zfc:config' features core matching colors hosts
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

An explicitly defined empty `features` style applies no features.

## Cache behavior

The default cache path is:

```text
${XDG_CACHE_HOME:-${ZDOTDIR:-$HOME/.cache}}/zsh-fancy-completions
```

Override it before load with a style. Loading only records the native completion
style, so the directory is created lazily by the completion system or
explicitly with:

```zsh
zstyle ':zfc:config' cache-dir /path/to/cache
```

Create it explicitly with:

```zsh
zfc_manage prepare-cache
```

Host discovery uses an in-memory cache. It is invalidated when a contributing
file or watched include directory changes. Force a refresh with:

```zsh
zfc_manage refresh hosts
```

Host resolution recognizes case-insensitive and indented `Host` and `Include`
directives, follows include cycles safely, treats quoted include paths
literally, and excludes wildcard and negated host patterns. `Match` conditions
are intentionally not treated as stable host aliases.

## Diagnostics

Run the read-only doctor before or after `compinit`:

```zsh
zfc_manage doctor
```

It reports the active profile and features, completion initialization, cache
writability, `compaudit` findings, changed styles, widget and key-binding
conflicts, Bash compatibility state, and lazy module state. It returns non-zero
only for actionable errors such as an insecure `fpath` or an unwritable cache
parent.

Other commands:

```zsh
zfc_manage features
zfc_manage cache-path
zfc_manage enable bash
zfc_manage --help
```

## Unload contract

```zsh
zfc_plugin_unload
```

Repeated sourcing is a no-op. Unload restores styles, public functions,
widgets, bindings, modules, metadata, and `fpath` entries owned by the first
successful load. If a user changes one of those values after load, unload
leaves the newer user value intact.

The plugin does not change shell options and does not install `compctl`
definitions, generic dot-prefixed helper functions, compatibility variables,
or alternate legacy namespaces.

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
