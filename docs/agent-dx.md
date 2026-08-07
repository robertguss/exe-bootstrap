# Agent DX tools (Lane C)

Installed by module `33-agent-dx`. Templates live under `templates/`.

| Tool | Binary | Purpose |
|------|--------|---------|
| [ast-grep](https://ast-grep.github.io/) | **`ast-grep`** (also `sg` via mise) | Structural search & replace |
| [gitleaks](https://github.com/gitleaks/gitleaks) | `gitleaks` | Secret scanning |
| [git-absorb](https://github.com/tummychow/git-absorb) | `git-absorb` | Auto fixup commits |
| [difftastic](https://difftastic.wilfred.me.uk/) | `difft` | Structural diffs |
| Templates | `templates/AGENTS*.md` | Copy into projects for agent instructions |

## ast-grep

On Linux, **`/bin/sg` is not ast-grep** (it is the shadow-group helper). Prefer the **`ast-grep`** binary from mise. After `mise activate`, mise’s `sg` may also work if it shadows `/bin/sg`.

```bash
ast-grep -p 'console.log($A)'
ast-grep -p 'old($A)' -r 'new($A)' --lang ts   # review before applying
# alias: agrep  (points at real ast-grep)
```

## gitleaks

```bash
gitleaks detect -v                 # whole repo
gitleaks protect --staged -v       # staged files only (pre-commit style)
```

Wire into **hk** per project when ready:

```bash
# example idea — actual hk.pkl syntax: see https://hk.jdx.dev/
# pre-commit: gitleaks protect --staged --verbose
hk install --mise
```

Also: `fnox scan` for fnox-oriented scanning.

## git-absorb

```bash
git add -p
git absorb              # creates fixup! commits
git rebase -i --autosquash main   # or: git absorb --and-rebase if supported
```

Use on feature branches you own; avoid absorb+rebase on shared mainline without coordination.

## difftastic

One-off:

```bash
difft file.go file.go.bak
git -c diff.external=difft diff
```

Optional permanent (user preference — not set globally by bootstrap):

```bash
git config --global diff.external difft
# undo: git config --global --unset diff.external
```

Bootstrap keeps **delta** as the default pager in `.gitconfig`; difftastic is opt-in so delta + lazygit stay stable.

## AGENTS.md templates

```bash
# From bootstrap clone
cp ~/Projects/exe-bootstrap/templates/AGENTS.md ./AGENTS.md
# Optional overlays — merge sections into AGENTS.md:
#   templates/AGENTS.python.md
#   templates/AGENTS.node.md
```

Fill the **Project-specific** section every time.

## Related

- [hk.md](hk.md) — enable hooks per repo  
- [POST_INSTALL.md](POST_INSTALL.md) — auth checklist  
- Grok Build respects `AGENTS.md` in the working tree  
