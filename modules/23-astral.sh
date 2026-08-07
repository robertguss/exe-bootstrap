#!/usr/bin/env bash
# Astral ecosystem (Python DX): uv, ruff, ty
# https://astral.sh/ — https://docs.astral.sh/uv/ — https://docs.astral.sh/ruff/ — https://github.com/astral-sh/ty

run() {
  export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"
  if ! have mise; then
    err "mise required"
    return 1
  fi
  eval "$(mise activate bash)" 2>/dev/null || true

  _mise_or_uv() {
    local name="$1"
    if have "$name"; then
      skip "$name present: $($name --version 2>/dev/null | head -1 || echo ok)"
      return 0
    fi
    log "installing $name via mise"
    if mise use -g "${name}@latest" 2>/dev/null || (mise install "$name" && mise use -g "$name"); then
      ok "mise: $name"
      return 0
    fi
    if have uv && [[ "$name" != "uv" ]]; then
      log "fallback: uv tool install $name"
      uv tool install "$name" && ok "uv tool: $name" && return 0
    fi
    if [[ "$name" == "uv" ]]; then
      log "fallback: official uv install script"
      curl -fsSL https://astral.sh/uv/install.sh | sh
      export PATH="${HOME}/.local/bin:${PATH}"
      have uv && ok "uv installed" && return 0
    fi
    warn "could not install $name"
  }

  _mise_or_uv uv
  export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"
  eval "$(mise activate bash)" 2>/dev/null || true

  _mise_or_uv ruff
  _mise_or_uv ty

  mise reshim 2>/dev/null || true
  eval "$(mise activate bash)" 2>/dev/null || true
  hash -r 2>/dev/null || true

  have uv && ok "uv $(uv --version 2>/dev/null | head -1)" || warn "uv missing"
  have ruff && ok "ruff $(ruff --version 2>/dev/null | head -1)" || warn "ruff missing"
  have ty && ok "ty $(ty --version 2>/dev/null | head -1)" || warn "ty missing"
}
