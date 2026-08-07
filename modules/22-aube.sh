#!/usr/bin/env bash
# aube — fast Node.js package manager (https://aube.jdx.dev/)

run() {
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! have mise; then
    err "mise required for aube"
    return 1
  fi

  eval "$(mise activate bash)" 2>/dev/null || true

  if have aube; then
    skip "aube already on PATH: $(aube --version 2>/dev/null | head -1 || echo yes)"
    return 0
  fi

  log "installing aube via mise"
  if mise use -g aube@latest 2>/dev/null || mise install aube && mise use -g aube; then
    ok "aube installed via mise"
  else
    # Fallback: npm global if node available
    if have npm; then
      log "fallback: npm install -g aube"
      npm install -g aube && ok "aube via npm" || warn "aube install failed"
    else
      warn "could not install aube"
    fi
  fi
}
