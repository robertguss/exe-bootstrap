#!/usr/bin/env bash
# hk — jdx git hook manager (https://hk.jdx.dev/)
# Installs the binary only. Hooks are per-repo: cd project && hk install --mise

run() {
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! have mise; then
    err "mise required for hk"
    return 1
  fi
  eval "$(mise activate bash)" 2>/dev/null || true

  if have hk; then
    skip "hk present: $(hk --version 2>/dev/null | head -1 || echo yes)"
  else
    log "installing hk via mise"
    if mise use -g hk@latest 2>/dev/null || (mise install hk && mise use -g hk); then
      ok "hk installed"
    else
      err "failed to install hk — see https://hk.jdx.dev/"
      return 1
    fi
  fi

  mise reshim 2>/dev/null || true
  if have hk; then
    ok "hk ready — in a git repo: hk init (if needed) && hk install --mise"
  fi
}
