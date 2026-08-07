# exe-bootstrap

Idempotent, modular dev environment for disposable [exe.dev](https://exe.dev) (Ubuntu) VMs.

```bash
git clone git@github.com:robertguss/exe-bootstrap.git ~/exe-bootstrap
cd ~/exe-bootstrap && ./install
exec zsh
```

## What you get

| Area | Tools |
|------|--------|
| Shell | zsh, Oh My Zsh, **starship**, **atuin**, **zoxide** |
| Secrets | **fnox** + **age** (fresh key per machine) |
| Toolchain | **mise** → Node LTS, Python, Go, Rust, Ruby, Elixir |
| Node PM | **aube** |
| Python | **uv**, **pipx**, cookiecutter |
| CLI | rg, fd, fzf, bat, eza, jq, yq, htop, tree, tmux, **trash-cli** |
| Git | gh, lazygit, delta + git identity |
| Editor | Neovim + **LazyVim** (stock) |
| Multiplexer | **herdr** |
| Agents | **Grok Build**, **Devin CLI** (+ Pi if present) |

## Add or remove a tool

1. **Module** — add `modules/XX-name.sh` with a `run()` function (copy any existing module).
2. **Enable** — add `XX-name` to `config/modules.enabled`.
3. **CLI list** — for mise tools, append to `config/packages.cli`.
4. Re-run: `./install` or `./install --only XX-name`.

Disable by commenting the line in `config/modules.enabled`.

## Commands

```bash
./install              # full install (idempotent)
./install --list       # show modules on/off
./install --only 60-fnox
./install --dry-run
```

## Fresh VM checklist

1. SSH into the exe.dev VM  
2. Clone this repo (GitHub integration or SSH key)  
3. `./install`  
4. **Back up** `~/.config/fnox/age.txt` offline  
5. `gh auth login`  
6. `atuin login` (optional)  
7. First-run auth: `grok`, `devin`  
8. Add secrets with fnox (see `config/fnox.toml.example`)

Personal shell tweaks go in **`~/.zshrc.local`** (not managed).

## Optional exe.dev setup-script

Not registered by default. To auto-bootstrap new VMs later:

```bash
# After the repo is public-or-accessible and install is solid:
cat setup-exe.dev.sh | ssh exe.dev new --setup-script /dev/stdin
# or set defaults — only when you intentionally want that
```

## Security

- Never commit API keys or `age.txt`
- Rotate any keys that previously lived in a Mac `.zshrc`
- This repo is intended to stay **private**

## Layout

```text
install                 # entrypoint
lib/common.sh           # helpers
modules/*.sh            # one concern each
config/modules.enabled  # feature flags
config/mise.toml        # language versions
config/packages.cli     # CLI tools via mise
home/                   # linked into $HOME
setup-exe.dev.sh        # optional thin first-boot
```

## License

Private / personal use.
