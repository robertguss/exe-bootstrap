#!/usr/bin/env bash
# starship + atuin (installed via official scripts if not already present;
# mise module may also install starship — both paths are idempotent)

run() {
  if have starship; then
    skip "starship already on PATH"
  else
    log "installing starship"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "${HOME}/.local/bin"
    ok "starship installed"
  fi

  if have atuin; then
    skip "atuin already on PATH"
  else
    log "installing atuin"
    curl -fsSL https://setup.atuin.sh | bash
    # setup script typically puts binary in ~/.atuin/bin or cargo
    if [[ -x "${HOME}/.atuin/bin/atuin" ]]; then
      mkdir -p "${HOME}/.local/bin"
      ln -sfn "${HOME}/.atuin/bin/atuin" "${HOME}/.local/bin/atuin"
    fi
    ok "atuin installed (run 'atuin login' later for sync)"
  fi
}
