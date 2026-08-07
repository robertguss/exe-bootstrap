# Agent instructions

Guidance for AI coding agents (Grok Build, Devin, Pi, etc.) working in this repository.

## Environment

- This project may run on **exe.dev** Ubuntu VMs or local Linux/macOS.
- Prefer tools already on the machine: `mise`, `rg`, `fd`, `sg` (ast-grep), `gitleaks`, `gh`, `nvim`.
- Language/tool versions: use **mise** (`mise.toml` / `.tool-versions`) — do not install random global versions.
- Node packages: prefer **aube** when available; otherwise the project’s documented package manager.
- Secrets: use **fnox** / env already injected — **never** commit API keys, `.env` with secrets, or age private keys.

## Safety

- Do **not** commit secrets. Run `gitleaks protect --staged` (or `gitleaks detect`) before committing if unsure.
- Do not force-push to `main`/`master` unless explicitly asked.
- Do not delete or rewrite git history unless asked.
- Prefer small, reviewable commits with clear messages.
- Destructive git helpers (`gbcmain`, hard reset, etc.) only when the user explicitly requests them.

## Workflow

1. Read relevant files before editing; prefer search (`rg`, `sg`) over guessing.
2. Match existing style, structure, and test patterns in the repo.
3. After substantive changes, run the project’s lint/tests (see below or README).
4. Summarize what changed and how to verify.

## Git

- Default branch is usually `main`.
- Use conventional, descriptive commit subjects (what/why, not “fix stuff”).
- For messy local commits on a feature branch, `git absorb` may help fold fixups (user preference).
- Open PRs with `gh pr create` when asked; include test plan notes.

## Project-specific

_Fill in for each repo:_

- **Stack:** (e.g. Node/TypeScript, Python, Go, …)
- **Install:** (e.g. `aube install` / `uv sync` / `mise install`)
- **Dev server:** (e.g. `npm run dev` / `mise run dev`)
- **Test:** (e.g. `npm test` / `pytest`)
- **Lint/format:** (e.g. `ruff check` / `eslint`)
- **Important paths:** (e.g. `src/`, `app/`)
- **Do not touch:** (e.g. generated code, vendor/)

## exe.dev notes (if applicable)

- HTTP is proxied via `https://<vm>.exe.xyz`; respect dev server host allowlists (Vite/Next).
- Ports 3000–9999 are commonly used for extra services.
- Prefer documenting share/port needs in the PR or README rather than assuming public access.

## Communication

- Be concise; prefer bullet lists for plans and results.
- Ask when requirements are ambiguous and a wrong choice is expensive.
- Do not invent APIs, files, or credentials that are not in the repo or provided by the user.
