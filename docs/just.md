# just

[just](https://github.com/casey/just) is installed globally via mise (`just` in `config/mise.toml` / `packages.cli`).

## Shell

```bash
just --list    # or: jl
just           # default recipe
just test      # named recipe
j test         # alias
```

## New project

```bash
# justfile
default:
    just --list

test:
    uv run pytest

lint:
    ruff check .
    ruff format --check .
```

## Node + aube

Bootstrap does **not** install global pnpm/bun. Prefer **aube** for installs; in a `justfile` you can still call whatever the repo needs:

```bash
install:
    aube install

dev:
    aubr dev
```

## Completions (optional)

```bash
# zsh — once, if you want:
just --completions zsh > ~/.oh-my-zsh/custom/plugins/just/_just
# then add just to plugins or rely on fpath; restart shell
```

Not automated by bootstrap yet; open an issue/PR in this repo if you want it in the zsh module.
