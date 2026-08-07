#!/usr/bin/env bash
# Lane B — Docker/ops: lazydocker, bottom, btop, dust, dua

run() {
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! have mise; then
    err "mise required"
    return 1
  fi
  eval "$(mise activate bash)" 2>/dev/null || true

  local tools=(lazydocker bottom btop dust dua)
  local t
  for t in "${tools[@]}"; do
    # bottom ships the `btm` binary
    if [[ "$t" == "bottom" ]] && have btm; then
      skip "bottom (btm) present"
      continue
    fi
    if have "$t"; then
      skip "$t present"
      continue
    fi
    log "installing $t via mise"
    if mise use -g "${t}@latest" 2>/dev/null || (mise install "$t" && mise use -g "$t"); then
      ok "mise: $t"
    else
      warn "could not install $t via mise"
    fi
  done

  mise reshim 2>/dev/null || true
  eval "$(mise activate bash)" 2>/dev/null || true
  hash -r 2>/dev/null || true

  # Verify (after activate so shims/bins are visible)
  have lazydocker && ok "lazydocker $(lazydocker --version 2>/dev/null | head -1 || echo ok)" || warn "lazydocker missing"
  if have btm; then
    ok "bottom/btm $(btm --version 2>/dev/null | head -1 || echo ok)"
  elif have bottom; then
    ok "bottom present"
  else
    warn "bottom/btm missing"
  fi
  have btop && ok "btop $(btop --version 2>/dev/null | head -1 || echo ok)" || warn "btop missing"
  have dust && ok "dust $(dust --version 2>/dev/null | head -1 || echo ok)" || warn "dust missing"
  have dua && ok "dua $(dua --version 2>/dev/null | head -1 || echo ok)" || warn "dua missing"

  if have docker; then
    ok "docker present (lazydocker needs the daemon when you use it)"
  else
    warn "docker not on PATH — lazydocker needs Docker installed/running"
  fi
}
