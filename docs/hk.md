# hk (git hooks)

[hk](https://hk.jdx.dev/) is installed globally by exe-bootstrap (`mise` / module `25-hk`).  
It does **not** attach hooks to every repo automatically.

## Per-project setup

```bash
cd your-project
# Create config if the project doesn't have one yet (see hk docs for hk.pkl)
hk init          # if available / when starting fresh
hk install --mise   # install git hooks; run via mise x so tool versions match
```

`--mise` makes hooks run with `mise x`, so Node/Python/etc. from the project’s mise config are on PATH.

## Useful commands

```bash
hk --version
hk check --all      # run configured checks
hk fix --all        # auto-fix where supported
hk install --mise   # (re)install hooks into .git/hooks
```

## Suggested first hooks (later lanes)

When you add **gitleaks** (Lane C) or **ruff** (Lane D), wire them in the project’s hk config so agents and humans share the same pre-commit gate.

## Docs

- https://hk.jdx.dev/
- https://hk.jdx.dev/mise_integration.html
