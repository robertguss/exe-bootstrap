#!/usr/bin/env bash
# Language runtimes via mise + Python tooling (uv, pipx, cookiecutter)

run() {
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! have mise; then
    err "mise not found — run module 20-mise first"
    return 1
  fi

  # Ensure core languages from config (erlang before elixir)
  log "ensuring language runtimes via mise"
  mise install erlang || warn "erlang install had issues"
  mise use -g erlang 2>/dev/null || true
  mise install node@lts python go rust ruby elixir || \
    mise install || warn "some language installs failed"
  mise reshim 2>/dev/null || true

  # Activate for current shell session paths
  eval "$(mise activate bash)" 2>/dev/null || true
  hash -r 2>/dev/null || true

  if have erl || have erlc; then
    ok "erlang available"
  else
    warn "erlang not on PATH yet — open a new shell or: eval \"\$(mise activate bash)\""
  fi
  if have elixir; then
    ok "elixir available"
  else
    warn "elixir not on PATH yet"
  fi

  # uv — fast Python package manager
  if have uv; then
    skip "uv already installed"
  else
    log "installing uv"
    curl -fsSL https://astral.sh/uv/install.sh | sh
    ok "uv installed"
  fi
  export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"

  # pipx
  if have pipx; then
    skip "pipx already installed"
  else
    if have uv; then
      uv tool install pipx 2>/dev/null || true
    fi
    if ! have pipx; then
      apt_install pipx || true
      pipx ensurepath 2>/dev/null || true
    fi
    have pipx && ok "pipx ready" || warn "pipx not available"
  fi

  # cookiecutter for npp alias
  if have cookiecutter; then
    skip "cookiecutter present"
  else
    if have uv; then
      uv tool install cookiecutter && ok "cookiecutter via uv"
    elif have pipx; then
      pipx install cookiecutter && ok "cookiecutter via pipx"
    else
      warn "could not install cookiecutter"
    fi
  fi
}
