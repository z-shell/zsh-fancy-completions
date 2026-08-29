# Project Guidelines: zsh-fancy-completions

This project follows the organization-wide [Z-Shell Organization Guidelines](https://github.com/z-shell/.github/blob/main/AGENTS.md).

## What this is

`zsh-fancy-completions` provides enhanced completion styles, fuzzy matching configurations, and host/process completion helpers.

## Conventions

- Adhere to the canonical [Zsh Plugin Standard](https://wiki.zshell.dev/community/zsh_plugin_standard).
- Follow the canonical
  [Zsh Scripting Standard](https://github.com/z-shell/.github/blob/main/.github/instructions/zsh-scripting.instructions.md).
- Entry point: `zsh-fancy-completions.plugin.zsh`

## Testing & Verification

Run the test suite and syntax checks locally using native Zsh:

```bash
# Run the ZUnit suite
zunit --tap tests/*.zunit

# Check syntax
zsh -n zsh-fancy-completions.plugin.zsh lib/*.zsh tests/cases/*.zsh tests/bench-hosts.zsh
```
