# Agent overlay — Python

Append or merge into the project `AGENTS.md` for Python repos.

## Tooling

- Prefer **uv** for envs and tools: `uv sync`, `uv run`, `uv tool run`.
- Prefer **ruff** for lint/format when configured.
- Use `pytest` unless the repo documents otherwise.
- Virtual env: project-local (`.venv`); activate only if the project expects it (`sv` alias sources `.venv`).

## Commands (adjust to repo)

```bash
uv sync
uv run pytest
uv run ruff check .
uv run ruff format .
```

## Secrets

- App secrets via **fnox** / environment — never hardcode.
- Do not commit `.env` files with real credentials.
