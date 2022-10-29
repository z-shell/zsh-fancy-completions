<h1 align="center"><p>
  <a href="https://github.com/z-shell/zi">
    <img src="https://github.com/z-shell/zi/raw/main/docs/images/logo.svg" alt="Logo" width="80px" height="80px" />
  </a>
❮ Plugin - Zsh fancy completions ❯
</p></h1>
<h2 align="center">
  <p>The plugin configures and delivers <kbd>TAB</kbd> completion with additional elements in conjunction with the <a href="https://github.com/zsh-users/zsh-completions">zsh-completion</a> project.</p>
</h2>
<!--
<div align="center">
  <img align="center" src="https://user-images.githubusercontent.com/59910950/182589498-56f595c6-36d0-4c72-a02f-328018a37f74.gif" alt="ajeetdsouza/zoxide" width="100%" height="auto" />
</div>
-->

## 💡 Wiki: [completion management](https://wiki.zshell.dev/docs/getting_started/overview#the-completion-management)

[**Zi**](https://github.com/z-shell/zi) allows to [manage and visualize](https://wiki.zshell.dev/docs/getting_started/overview#snippets-as-completion) each completion in every plugin. Recommended to install using [meta-plugins](https://github.com/z-shell/zsh-fancy-completions/#meta-plugins--for-syntax).

## Options

- `extended_glob` # Needed for file modification glob modifiers with compinit.
- `bad_pattern` # If a pattern for filename generation is badly formed, print an error message.
  > **Note** - If this option is unset, the pattern will be left unchanged.
- `bang_hist` # Perform textual history expansion, csh-style, treating the character `!' specially.
- `always_to_end` # Move cursor to the end of a completed word.
- `path_dirs` # Perform path search even on command names with slashes.
- `auto_menu` # Show completion menu on a successive tab press.
- `auto_list` # Automatically list choices on ambiguous completion.
- `hist_ignore_all_dups` # Remove older duplicate entries from history.
- `hist_expire_dups_first` # Expire a duplicate event first when trimming History.
- `hist_ignore_dups` # Do not record an event that was just recorded again.
- `hist_reduce_blanks` # Remove superfluous blanks from history items.
- `hist_find_no_dups` # Do not display a previously found event.
- `hist_ignore_space` # Do not record an event starting with a space.
- `hist_save_no_dups` # Do not write a duplicate event to the history file.
- `hist_verify` # Do not execute immediately upon history expansion.
- `append_history` # Allow multiple terminal sessions to all append to one zsh command history.
- `extended_history` # Show timestamp in history.
- `inc_append_history` # Write to the history file immediately, not when the shell exits.
- `share_history` # Share history between different instances of the shell.
- `menu_complete` # Do not autoselect the first completion entry.
- `flow_control` # Disable start/stop characters in shell editor.
- `auto_param_slash` # If a parameter is completed whose content is the name of a directory, then add a trailing slash instead of a space.
- `complete_aliases` # Prevents aliases on the command line from being internally substituted before completion is attempted. The effect is to make the alias a distinct command for completion purposes.
- `complete_in_word` # If unset, the cursor is set to the end of the word if completion is started. Otherwise it stays there and completion is done from both ends.
- `auto_param_keys` # If a parameter name was completed and a following character (normally a space) automatically inserted, and the next character typed is one of those that have to come directly after the name (like `}`, `:`, etc.), the automatically added character is deleted, so that the character typed comes immediately after the parameter name. Completion in a brace expansion is affected similarly: the added character is a `,`, which will be removed if `}` is typed next.

---

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

> **Note**
>
> - To avoid duplicates, unwanted or not comptible plugins, simply add its name to `skip` ice-modifier before loading meta plugin, e.g:

```zsh
zi light-mode for \
  z-shell/z-a-meta-plugins \
    skip'rust default-ice unscope' @annexes \
    skip'zsh-autosuggestions' @zsh-users+fast
```

The [@zsh-users+fast](https://wiki.zshell.dev/ecosystem/annexes/meta-plugins#@zsh-users+fast) meta-plugin contains the following:

- [z-shell/F-Sy-H](https://github.com/z-shell/F-Sy-H),
- [zsh-autosuggestions](https://github.com/z-shell/zsh-autosuggestions),
- [zsh-completions](https://github.com/z-shell/zsh-completions),
- [z-shell/zsh-fancy-completions](https://github.com/z-shell/zsh-fancy-completions).

Additional example of how to install [many plugins](https://wiki.zshell.dev/ecosystem/annexes/meta-plugins#available-meta-plugins):

```zsh
zi light-mode for \
  z-shell/z-a-meta-plugins @annexes \
  @fuzzy skip'F-Sy-H' @z-shell @console-tools \
  @zsh-users+fast @romkatv @ext-git @rust-utils
```

> **Note**
>
> - To create your group of plugins as meta-plugins propose them in a new [issue](https://github.com/z-shell/z-a-meta-plugins/issues/new)
> - Prefix @ used to avoid syntax conflicts, e.g: zi light @meta-plugin-name.
> - Before installing any plugin visit the original repository where available to verify that system is supported and meets other requirements.
