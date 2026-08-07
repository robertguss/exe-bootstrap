# Agent overlay — Python

Append or merge into the project `AGENTS.md` for Python repos.

## Tooling (Astral)

- Prefer **uv** for envs and tools: `uv sync`, `uv run`, `uv add`, `uv tool install`.
- Prefer **ruff** for lint + format.
- Prefer **ty** for type checking when the project uses it.
- Use `pytest` via `uv run pytest` unless the repo documents otherwise.
- Virtual env: project-local (`.venv`); activate only if the project expects it (`sv` alias sources `.venv`).
- Do not invent a second package manager (pip/poetry/pipenv) unless the repo already uses it.

## Commands (adjust to repo)

```bash
uv sync
uv run pytest
ruff check .
ruff check . --fix
ruff format .
ty check
```

## Secrets

- App secrets via **fnox** / environment — never hardcode.
- Do not commit `.env` files with real credentials.
