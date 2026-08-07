# Agent overlay — Node / TypeScript

Append or merge into the project `AGENTS.md` for JS/TS repos.

## Tooling

- Prefer **mise** for Node version; prefer **aube** for installs when available.
- Fall back to the lockfile’s package manager (`package-lock.json` → npm, `pnpm-lock.yaml` → pnpm, etc.).
- Prefer project scripts: `npm test`, `npm run lint`, `npm run build`.

## Commands (adjust to repo)

```bash
# with aube when available
aube install
aubr test
aubr lint

# or npm/pnpm as documented
npm ci
npm test
npm run lint
```

## Secrets

- Use **fnox** / env for `API_KEY`, tokens, etc.
- Never commit `.env` with real secrets; `.env.example` without values is OK.
