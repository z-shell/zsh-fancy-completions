<h1 align="center">
  <p>
    <a href="https://github.com/z-shell/zi">
      <img src="https://github.com/z-shell/zi/raw/main/docs/images/logo.png" alt="Logo" width="80px" height="80px" />
    </a>
    ❮ Zsh fancy completions ❯
  </p>
</h1>
<h2 align="center">
  <p>The plugin provides various completions tools, libraries and integrations.</p>
</h2>

## 💡 [**Zi**](https://github.com/z-shell/zi) Wiki: [completion management](https://wiki.zshell.dev/docs/getting_started/overview#the-completion-management)

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

Additional example of how to install [many plugins](https://wiki.zshell.dev/ecosystem/annexes/meta-plugins#available-meta-plugins).
