<h1 align="center">
  <p>
    <a href="https://github.com/z-shell/zi">
      <img src="https://github.com/z-shell/zi/raw/main/docs/images/logo.png" alt="Logo" width="80px" height="80px" />
    </a>
    ❮ Zsh fancy completions ❯
  </p>
</h1>
<h2 align="center">
  <p>The plugin provides various completions tools, libraries, and integrations.</p>
</h2>

## 💡 [**Zi**](https://github.com/z-shell/zi) Wiki: [completion management](https://wiki.zshell.dev/docs/getting_started/overview#the-completion-management)

### Requirements

- Zsh >= 5.0.0

### Completion settings

| Variable                                | Description                                    | Default      |
| --------------------------------------- | ---------------------------------------------- | ------------ |
| <kbd>COMPLETION_WAITING_DOTS</kbd>      | Show `…` while waiting for slow completions    | <kbd>0</kbd> |
| <kbd>MANPAGE_COMPLETION</kbd>           | Enable manual page name completion             | <kbd>0</kbd> |
| <kbd>COMPLETION_UMLAUT_MATCHING</kbd>   | Enable German umlaut substitution in matching  | <kbd>0</kbd> |

### Features

- Case-insensitive, partial-word, and substring completion
- SSH/SCP/RSYNC hostname completion from known_hosts and ssh config
- Process/kill completion with colored output
- Manual page completion by section (opt-in)
- History-based completion with deduplication
- Fish-style command highlighting
- Fuzzy matching with configurable error tolerance
- Docker/Podman option stacking (auto-detected)
- Git enhanced completion (branch ordering, descriptions)
- Systemctl force-list on Linux (auto-detected)
- Automatic command rehashing for newly installed programs

### Unloading

The plugin follows the [Z-Shell Plugin Standard](https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function) and can be unloaded cleanly:

```zsh
zsh-fancy-completions_plugin_unload
```

### Install `zsh-fancy-completions`

#### [Standard syntax](https://wiki.zshell.dev/docs/guides/syntax/common#standard-syntax)

```zsh
zi light zsh-fancy-completions
```

#### [Turbo mode](https://wiki.zshell.dev/docs/getting_started/overview#turbo-mode-zsh--53) + "For" syntax

```zsh
zi wait lucid for \
  z-shell/zsh-fancy-completions
```

#### [Meta-plugins](https://wiki.zshell.dev/ecosystem/annexes/meta-plugins) + "For" syntax

Install annexes that provide additional capabilities and the curated, optimal [ice-modifiers](https://wiki.zshell.dev/docs/guides/syntax/ice-modifiers) automatically applied via a single, friendly label.

```zsh
zi light-mode for \
  z-shell/z-a-meta-plugins @annexes @zsh-users+fast
```

The [@zsh-users+fast](https://wiki.zshell.dev/ecosystem/annexes/meta-plugins#@zsh-users+fast) meta-plugin contains the following:

- [z-shell/F-Sy-H](https://github.com/z-shell/F-Sy-H),
- [zsh-autosuggestions](https://github.com/z-shell/zsh-autosuggestions),
- [zsh-completions](https://github.com/z-shell/zsh-completions),
- [z-shell/zsh-fancy-completions](https://github.com/z-shell/zsh-fancy-completions).

Additional examples of how to install [many plugins](https://wiki.zshell.dev/ecosystem/annexes/meta-plugins#available-meta-plugins).
