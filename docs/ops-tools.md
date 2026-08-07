# Ops tools (Lane B)

Installed by module `32-ops-tools` via mise.

| Tool | Binary | Alias | Use for |
|------|--------|-------|---------|
| [lazydocker](https://github.com/jesseduffield/lazydocker) | `lazydocker` | `lzd` | Containers, images, logs (needs Docker daemon) |
| [bottom](https://github.com/ClementTsang/bottom) | `btm` | `bottom` | CPU/mem/net process TUI |
| [btop](https://github.com/aristocratos/btop) | `btop` | — | Alternate system monitor |
| [dust](https://github.com/bootandy/dust) | `dust` | `duh` | Disk usage by directory (tree) |
| [dua](https://github.com/Byron/dua-cli) | `dua` | — | Interactive disk usage (`dua i`) |

## Quick start

```bash
lzd                 # lazydocker
btm                 # bottom
btop
dust ~              # or: duh ~
dua i /             # interactive, navigate and delete with care
```

## Docker note

`lazydocker` talks to the local Docker socket. On exe.dev, Docker is usually available; if `lzd` errors, check:

```bash
docker info
groups   # should include docker (may need re-login after group add)
```

## Related

- lazygit (git TUI) — module `31-git-tools`
- `./doctor` — verifies these binaries are on PATH
