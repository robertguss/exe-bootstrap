# Astral ecosystem (Python DX)

Module `23-astral` installs the core [Astral](https://astral.sh/) CLIs via mise (with fallbacks).

| Tool | Role | Docs |
|------|------|------|
| **uv** | Python package & project manager | https://docs.astral.sh/uv/ |
| **ruff** | Lint + format | https://docs.astral.sh/ruff/ |
| **ty** | Type checker | https://github.com/astral-sh/ty |

Python runtime itself comes from **mise** (`python = "latest"` in `config/mise.toml`).

## Everyday commands

```bash
# Project
uv init
uv add requests
uv sync
uv run python main.py
uv run pytest

# Lint / format
ruff check .
ruff check . --fix
ruff format .

# Types
ty check
```

## Global tools via uv

```bash
uv tool install cookiecutter   # already used by bootstrap for npp
uv tool list
uv tool upgrade ruff           # if you installed ruff via uv tool instead of mise
```

Bootstrap prefers **mise** for `uv` / `ruff` / `ty` so versions sit with your other global tools. Either path is fine.

## Agents

Point project `AGENTS.md` at:

```text
uv sync && uv run pytest
ruff check . && ruff format .
ty check
```

See `templates/AGENTS.python.md`.

## Not installed here

Other Astral experiments may appear over time; this module sticks to **uv + ruff + ty**. Ask to extend the module when you want more.
