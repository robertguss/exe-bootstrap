# Post-install guide

This is a focused checklist for **after** `./install` on a fresh VM.  
For full project docs, see the root [README.md](../README.md).

## P0 — Do now

```bash
exec zsh
# From the bootstrap clone:
./doctor
# Back up ~/.config/fnox/age.txt offline (private key)
ls -la ~/.config/fnox/age.txt
grep "public key:" ~/.config/fnox/age.txt
```

## P1 — Logins (interactive)

| Tool | Command | Notes |
|------|---------|--------|
| GitHub CLI | `gh auth login` | Skip if `gh auth status` already OK |
| Grok Build | `grok` | [x.ai/build](https://x.ai/build) coding agent |
| Devin CLI | `devin` | Installer does not finish login non-interactively |
| Pi / Shelley | (image-dependent) | Often preinstalled on exeuntu |

```bash
gh auth status || gh auth login
grok --version && grok
devin --version && devin
```

## P2 — Recommended

| Task | Command / action |
|------|------------------|
| LazyVim plugins | `nvim` (wait for install) |
| Local terminal font | Nerd Font on **client**, not VM |
| Atuin history sync | `atuin import auto` then `atuin login` or `register` |
| Secrets | Use **fnox** + age — not `.zshrc` exports |
| Git signing | Not configured; add GPG/SSH signing yourself if needed |

## P3 — Optional

- `herdr` / `hr` — agent multiplexer  
- **hk** — already on PATH; enable per repo with `hk install --mise` (see [hk.md](hk.md))  
- **Agent DX** — `sg`, `gitleaks`, `git-absorb`, `difft`; copy `templates/AGENTS.md` into projects ([agent-dx.md](agent-dx.md))  
- Edit `~/.zshrc.local` for machine-only tweaks  
- `ssh exe.dev share port …` when exposing dev servers  
- Starship: `home/starship.toml` in the repo  

## Copy/paste checklist

```text
[ ] exec zsh
[ ] ./doctor
[ ] mise, node, nvim, grok, hk on PATH
[ ] ~/.config/fnox/age.txt backed up offline
[ ] gh auth login (if needed)
[ ] grok first-run auth
[ ] devin first-run auth
[ ] nvim first launch (LazyVim plugins)
[ ] atuin import/login (optional)
[ ] API keys in fnox (recommended)
[ ] Nerd Font on local terminal
[ ] (per project) hk install --mise
```

## Verify

```bash
./doctor
# or manually:
echo $SHELL
mise --version && node -v && python --version
command -v rg fd bat eza zoxide starship atuin herdr fnox aube hk
command -v grok devin nvim gh lazygit delta
test -f ~/.config/fnox/age.txt && echo "age key: ok"
test -L ~/.zshrc && echo "zshrc: linked from repo"
```
