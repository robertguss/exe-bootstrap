# exe-bootstrap

Modular, **idempotent** dev environment for disposable [exe.dev](https://exe.dev) Ubuntu VMs (works on plain Ubuntu 24.04 too).

Clone once, run `./install`, re-run anytime. Add or remove tools by editing modules — no need to rebuild a machine image.

**Repo:** [github.com/robertguss/exe-bootstrap](https://github.com/robertguss/exe-bootstrap) (private)

---

## Quick start (fresh VM)

```bash
# 1. SSH into the VM, then clone
git clone git@github.com:robertguss/exe-bootstrap.git ~/exe-bootstrap
# or: git clone https://github.com/robertguss/exe-bootstrap.git ~/exe-bootstrap

cd ~/exe-bootstrap
./install
exec zsh
```

Then complete **[After install: required & optional steps](#after-install-required--optional-steps)** below. The installer configures tools; it does **not** complete interactive logins or secret backups for you.

---

## Design goals

| Goal | How |
|------|-----|
| Disposable VMs | One clone + `./install` reproduces the environment |
| Easy add/remove | One module file + line in `config/modules.enabled` |
| Safe re-runs | Modules skip work that is already done |
| No secrets in git | fnox + age; keys stay on disk / offline backup |
| exe.dev friendly | Thin optional `setup-exe.dev.sh`; primary path is manual clone |

---

## What gets installed

| Area | Tools |
|------|--------|
| **Shell** | zsh (default login shell), Oh My Zsh, plugins (`git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`), **starship**, **atuin**, **zoxide** |
| **Secrets** | **fnox** + **age** (generates a fresh key at `~/.config/fnox/age.txt` if missing) |
| **Toolchain** | **mise** managing Node (latest LTS), Python, Go, Rust, Ruby, Erlang, Elixir |
| **Node** | **aube** package manager |
| **Python** | **uv**, **pipx**, **cookiecutter** (for `npp` alias) |
| **CLI** | ripgrep, fd, fzf, bat, eza, jq, yq, htop, tree, tmux, **trash-cli** |
| **Git** | identity in `home/.gitconfig`, **gh**, **lazygit**, **git-delta** |
| **Editor** | Neovim + stock **LazyVim** starter (`~/.config/nvim`) |
| **Multiplexer** | **herdr** (`hr` alias) |
| **Agents** | **Grok Build** ([x.ai/build](https://x.ai/build)), **Devin CLI**, Pi/Shelley if already on the image |

Dotfiles are **symlinked** from `home/` into `$HOME`. Machine-specific overrides go in **`~/.zshrc.local`** (created empty; never overwritten by install after first create).

---

## Commands

```bash
./install                 # full install (idempotent)
./install --list          # modules on/off
./install --only 60-fnox  # single module (prefix or full id)
./install --dry-run       # show what would run
./install --help
```

---

## After install: required & optional steps

Work through this on **every new VM**. The install script only prints a short reminder; this section is the source of truth.

### Priority overview

| Priority | What | Why |
|----------|------|-----|
| **P0 — do immediately** | New shell, back up age key | Shell env + secrets unusable without these |
| **P1 — before real work** | GitHub auth, Grok Build, Devin | Clone private repos / use agents |
| **P2 — recommended** | LazyVim first launch, atuin, fnox secrets | Editor plugins + history + API keys |
| **P3 — optional** | herdr habits, starship tweaks, exe.dev sharing | Quality of life |

---

### P0 — Immediately after `./install`

#### 1. Start a new shell

```bash
exec zsh
# or disconnect and SSH back in
```

Confirm:

```bash
echo $SHELL          # should end with /zsh
mise --version
node -v              # LTS via mise
which grok nvim herdr fnox
```

#### 2. Back up the age private key (required if you use fnox)

Install generates (if missing):

```text
~/.config/fnox/age.txt
```

This file decrypts secrets. **Copy it offline** (password manager, encrypted USB, 1Password secure note, etc.). Do **not** commit it.

```bash
# Show public key only (safe to store in fnox recipients)
grep "public key:" ~/.config/fnox/age.txt

# Confirm permissions
ls -la ~/.config/fnox/age.txt   # expect -rw------- (600)
```

If you destroy the VM without a backup, encrypted secrets are gone for that key.

---

### P1 — Auth & accounts (interactive)

These tools are **installed** but need **you** to log in. None of this is automated (by design).

#### GitHub CLI (`gh`)

Needed for private repos, PRs, `gh browse`, etc.

```bash
gh auth status          # see if already logged in
gh auth login           # if not — HTTPS or SSH; use your robertguss account
gh auth setup-git       # optional: use gh as git credential helper
```

**SSH note:** first push/clone via `git@github.com` may need:

```bash
ssh-keyscan -t ed25519,rsa github.com >> ~/.ssh/known_hosts
# Ensure this VM has an SSH key loaded or use exe.dev GitHub integration
```

**exe.dev:** you can also attach the [GitHub integration](https://exe.dev/docs/integrations-github.md) so private clones work without storing a PAT on the VM.

#### Grok Build (coding agent)

Install: official script in module `70-agents` ([x.ai/build](https://x.ai/build)).

```bash
grok --version
grok                    # first run: complete browser / API auth as prompted
# or set API key if you use key-based auth — prefer fnox, not plain .zshrc
```

Docs: <https://docs.x.ai/build/overview>  
Update later: `grok update`

#### Devin CLI

Binary is installed; **login is interactive** and was skipped in non-interactive installs.

```bash
devin --version
devin                   # complete Cognition / Devin account login
```

Docs: <https://docs.devin.ai/cli>

#### Pi / Shelley (exe.dev image agents)

Often preinstalled on exeuntu. Bootstrap only checks presence; it does not reconfigure auth.

```bash
command -v pi
# Follow current exe.dev / Shelley docs if login is required on your image
```

---

### P2 — Recommended one-time setup

#### LazyVim / Neovim (first launch)

Stock LazyVim starter is cloned to `~/.config/nvim`. **Plugin install happens on first open:**

```bash
nvim
# Wait for lazy.nvim to fetch plugins; quit when finished (:q)
```

**Fonts:** icons need a [Nerd Font](https://www.nerdfonts.com/) in **your local terminal** (or VS Code remote terminal font), not on the VM.

#### Atuin (shell history)

Installed and hooked in `.zshrc`. Sync is optional:

```bash
atuin import auto       # import existing shell history once
atuin register          # new account — or:
atuin login             # existing account
```

Skip if you only want local history.

#### fnox secrets (API keys, tokens)

Do **not** put secrets in `.zshrc` or this git repo.

Typical first-time flow (after age key exists):

```bash
# In a project or in ~/.config/fnox/
fnox init
fnox provider add age --id main --recipients "$(grep 'public key:' ~/.config/fnox/age.txt | awk '{print $NF}')"
fnox secret set SOME_API_KEY --provider main   # prompts for value
fnox exec -- some-command                      # run with secrets
# Shell integration is already in .zshrc via: eval "$(fnox activate zsh)"
```

See `config/fnox.toml.example` and <https://fnox.jdx.dev/>.

**Migrate keys that used to live in your Mac `.zshrc`** (Gemini, Linear, Hetzner, etc.) into fnox, and **rotate** any key that was ever committed or pasted into chat.

#### Git identity

Already set via linked `home/.gitconfig`:

| Field | Value |
|-------|--------|
| `user.name` | Robert Guss |
| `user.email` | robertguss@gmail.com |
| `core.editor` | nvim |
| pager | delta |

Override per-repo with `git config user.email ...` if needed. Signing keys (GPG/SSH commit signing) are **not** configured — add manually if you use them.

#### Cookiecutter / `npp` alias

```bash
npp    # cookiecutter https://github.com/robertguss/cookiecutter-modern-python-projects
```

Needs network; first run may prompt for template variables.

---

### P3 — Optional / as needed

| Item | Action |
|------|--------|
| **herdr** | Run `herdr` or `hr` to start agent-aware sessions; `herdr update` to upgrade |
| **Starship** | Config is linked from `home/starship.toml` → `~/.config/starship.toml`; edit in repo or replace link |
| **Personal aliases** | Edit `home/aliases.zsh` in the repo, or use `~/.zshrc.local` for this VM only |
| **Default shell failed?** | `sudo chsh -s "$(command -v zsh)" "$USER"` then re-login |
| **Docker** | Usually preinstalled on exe.dev; add your user is often already in `docker` group |
| **exe.dev HTTP proxy** | Dev servers: see [Next.js/Vite notes](https://exe.dev/docs/faq/nextjs-and-friends.md); share port with `ssh exe.dev share port <vm> <port>` |
| **Auto setup-script** | Not enabled by default; see [Optional first-boot script](#optional-exedev-first-boot-script) |

---

### Post-install checklist (copy/paste)

```text
[ ] exec zsh  (or new SSH session)
[ ] mise / node / nvim / grok respond on PATH
[ ] Backed up ~/.config/fnox/age.txt offline
[ ] gh auth login  (if needed)
[ ] grok  — completed first-run auth
[ ] devin — completed first-run auth
[ ] nvim  — first launch finished plugin install
[ ] atuin import / login  (optional)
[ ] Moved API keys into fnox  (optional but recommended)
[ ] Nerd Font set on local terminal client
```

---

## Modules reference

Enabled list: `config/modules.enabled` (comment out a line to skip).

| Module | Responsibility |
|--------|----------------|
| `00-base` | apt essentials, trash-cli, dirs (`~/bin`, `~/Projects`, …) |
| `10-zsh-omz` | zsh, default shell, Oh My Zsh, autosuggestions + syntax-highlighting |
| `15-starship-atuin` | starship + atuin installers |
| `20-mise` | mise binary + link `config/mise.toml` + `mise install` |
| `21-languages` | language runtimes, uv, pipx, cookiecutter; erlang before elixir |
| `22-aube` | aube via mise |
| `30-cli-tools` | CLI from `config/packages.cli` (+ apt fallbacks) |
| `31-git-tools` | gh, lazygit, delta |
| `40-neovim-lazyvim` | neovim + LazyVim starter (won’t clobber existing LazyVim) |
| `50-herdr` | herdr install/update |
| `60-fnox` | fnox + age key generation |
| `70-agents` | Grok Build, Devin CLI; detect Pi/Shelley |
| `90-dotfiles` | symlink `.zshrc`, aliases, `.gitconfig`, starship.toml |

Modules are sourced in filename order. Each defines `run()`.

---

## Add or remove a tool

### Add

1. Copy an existing file under `modules/` → `modules/XX-mytool.sh`.
2. Implement `run()` using helpers from `lib/common.sh` (`apt_install`, `have`, `log`, `ok`, `skip`, `link_file`, …).
3. Add `XX-mytool` to `config/modules.enabled`.
4. For mise-managed CLIs, add a line to `config/packages.cli` and/or `config/mise.toml`.
5. Commit, push, run `./install` or `./install --only XX-mytool`.

### Remove

1. Comment out or delete the id in `config/modules.enabled`.
2. Optionally delete the module file and drop tools from `config/mise.toml` / `packages.cli`.
3. Re-run install (does not always uninstall packages already on disk — remove manually if you need disk space).

### Personal vs shared

| Kind | Where |
|------|--------|
| Shared aliases, git identity, starship | `home/` in this repo |
| This-VM-only exports, experiments | `~/.zshrc.local` |
| Secrets | fnox + age, never git |

---

## Repository layout

```text
exe-bootstrap/
├── install                 # entrypoint
├── setup-exe.dev.sh        # optional thin first-boot (clone + install)
├── lib/common.sh           # logging, apt, symlink helpers
├── modules/                # numbered install steps
├── config/
│   ├── modules.enabled     # feature flags
│   ├── mise.toml           # languages + many CLIs
│   ├── packages.cli        # CLI list for 30-cli-tools
│   ├── omz-plugins.txt     # documentation of OMZ plugins
│   └── fnox.toml.example
├── home/
│   ├── .zshrc              # → ~/.zshrc
│   ├── aliases.zsh         # → ~/.aliases.zsh
│   ├── .gitconfig          # → ~/.gitconfig
│   └── starship.toml       # → ~/.config/starship.toml
└── README.md               # this file
```

---

## Optional exe.dev first-boot script

Primary workflow is still **SSH → clone → `./install`**.

If you later want auto-bootstrap on `ssh exe.dev new`:

```bash
# One-off for a new VM (script must stay small; it clones this private repo)
export EXE_BOOTSTRAP_REPO=git@github.com:robertguss/exe-bootstrap.git
cat setup-exe.dev.sh | ssh exe.dev new --setup-script /dev/stdin
```

Requirements for unattended clone: GitHub integration or deploy key on the new VM.  
Do **not** put secrets in the setup script. After boot, still do the **P0/P1** steps (age backup, agent logins).

---

## Security

- Keep this repository **private**.
- Never commit `age.txt`, `.env`, or API keys.
- `.gitignore` blocks common secret paths; double-check before `git add -f`.
- Rotate any credential that lived in plain shell config or chat logs.
- Prefer **fnox** (or exe.dev integrations) over `export KEY=...` in dotfiles.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Commands missing after install | `exec zsh` or new SSH session; ensure `~/.local/bin` on PATH |
| `mise` tools not found | `eval "$(mise activate zsh)"` then `mise reshim` |
| Elixir / `erl: not found` | `./install --only 21-languages` (erlang must install first) |
| `chsh` failed | `sudo chsh -s "$(command -v zsh)" "$USER"` and re-login |
| LazyVim / nvim errors | First launch needs network; try `nvim` again; backup and re-run `./install --only 40-neovim-lazyvim` only if config isn’t customized |
| `gh` / git SSH host key errors | `ssh-keyscan -t ed25519,rsa github.com >> ~/.ssh/known_hosts` |
| Devin “login canceled” during install | Normal in non-interactive runs; run `devin` yourself |
| Dotfile conflict | Install backs up to `*.bak.<timestamp>` then symlinks managed files |
| Want stock OMZ zshrc back | Remove symlink and restore a `.bak.*` file |

Re-run everything safely:

```bash
cd ~/exe-bootstrap && git pull && ./install
```

---

## Related links

- [exe.dev docs](https://exe.dev/docs.md)
- [exe.dev customization / setup scripts](https://exe.dev/docs/customization.md)
- [mise](https://mise.jdx.dev/) · [fnox](https://fnox.jdx.dev/) · [aube](https://aube.jdx.dev/)
- [Grok Build](https://x.ai/build) · [Devin CLI](https://docs.devin.ai/cli)
- [LazyVim](https://www.lazyvim.org/) · [herdr](https://herdr.dev/) · [starship](https://starship.rs/) · [atuin](https://atuin.sh/)

---

## License

Private / personal use.
