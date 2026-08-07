# Agent overlay — Node / TypeScript

Append or merge into the project `AGENTS.md` for JS/TS repos.

## Tooling

- Prefer **mise** for Node version.
- Prefer **aube** for package installs — it works with existing lockfiles (npm / pnpm / yarn style) without requiring a separate global pnpm/bun install.
- Prefer project scripts via aube (`aubr test`) or the repo’s documented commands.
- If a **justfile** exists, prefer `just` recipes for install/test/dev.

## Commands (adjust to repo)

```bash
aube install
aubr test
aubr lint

# if justfile present
just
just test
```

## Secrets

- Use **fnox** / env for `API_KEY`, tokens, etc.
- Never commit `.env` with real secrets; `.env.example` without values is OK.
