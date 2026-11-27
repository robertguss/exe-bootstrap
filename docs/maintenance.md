# Rust Build Caching & VM Maintenance

## Shared Cargo cache with `mr-boxington` (`mbx`)

Rust builds across git worktrees (e.g., `t3` / agent worktrees) normally create independent multi-gigabyte `target/` directories and recompile identical crates from scratch.

`exe-bootstrap` enables `mise`'s native `mr_boxington` integration in `config/mise.toml`:

```toml
rust = { version = "latest", mr_boxington = true }
mr-boxington = "latest"
```

- Interactive shells use `mise activate`, and non-interactive shells (`t3`, Claude, Codex, SSH one-liners) pick up `~/.local/share/mise/shims` via `~/.zshenv` and `~/.profile`, so plain `cargo build` / `cargo test` automatically run through `mbx`.
- Global cache limits are managed in `config/mbx.toml` (linked to `~/.config/mbx/config.toml`):
  - `gc.max_total_size = "50GiB"` — combined cap for the action store, managed targets, and incremental state.
  - `gc.min_free_size = "30GiB"` — low-disk safeguard that sweeps more aggressively if free space drops below 30 GiB.
  - `target.evict_first = [".t3/worktrees", ".claude/worktrees"]` — agent worktree targets are evicted before primary checkouts.

Useful commands:

```bash
mbx doctor
mbx stats
mbx gc --dry-run
```

## Updating languages and tools (`dev-box-update`)

Run manually when you want to upgrade `mise`, all tools in `config/mise.toml`, and non-`mise` runtimes (`rustup`, `bun`, `elan`, `herdr`):

```bash
dev-box-update --dry-run   # preview outdated tools
dev-box-update             # upgrade tools
dev-box-update --prune     # upgrade and prune old mise versions
dev-box-update --apt       # also run apt-get update && upgrade
```

## Periodic disk cleanup (`dev-box-cleanup`)

Linked to `~/.local/bin/dev-box-cleanup` and scheduled every 6 hours via `systemd --user` (`dev-box-cleanup.timer`, running at low CPU/IO priority and logging to `~/.local/state/dev-box-cleanup.log`):

- Runs `mbx gc`
- Prunes unused anonymous Docker volumes (`docker volume prune -f`)
- Removes old Claude Code binaries in `~/.local/share/claude/versions/` (preserving the active symlink target)
- Prunes `uv` and `pnpm` caches
- Removes stale dev scratch files in `/tmp` older than 3 days (only known scratch patterns owned by `$USER` and not open)
- If `/` reaches `>= 80%` usage (or `--force-high-water` is passed), cleans idle unmanaged `target/` directories and package caches while skipping any active `cargo`/`rustc` builds or open files.

```bash
dev-box-cleanup --dry-run
systemctl --user status dev-box-cleanup.timer
```
