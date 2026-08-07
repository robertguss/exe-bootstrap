#!/usr/bin/env bash
# starship + atuin
# Atuin: non-interactive defaults — no register/login prompts during ./install.
# Shell init comes from home/.zshrc (module 90-dotfiles), not the upstream setup script.

run() {
  export PATH="${HOME}/.local/bin:${HOME}/.atuin/bin:${PATH}"

  if have starship; then
    skip "starship already on PATH"
  else
    log "installing starship"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "${HOME}/.local/bin"
    ok "starship installed"
  fi

  if have atuin; then
    skip "atuin already on PATH: $(atuin --version 2>/dev/null | head -1 || echo yes)"
  else
    log "installing atuin (non-interactive)"
    # Prefer mise — binary only, no prompts, does not mutate ~/.zshrc
    if have mise || [[ -x "${HOME}/.local/bin/mise" ]]; then
      export PATH="${HOME}/.local/bin:${PATH}"
      eval "$(mise activate bash)" 2>/dev/null || true
      if mise use -g atuin@latest 2>/dev/null || (mise install atuin && mise use -g atuin); then
        ok "atuin via mise"
      else
        warn "mise atuin failed; falling back to official setup --non-interactive"
        curl -fsSL https://setup.atuin.sh | bash -s -- --non-interactive
      fi
    else
      # Official installer with explicit non-interactive flag (skips import/register prompts)
      curl -fsSL https://setup.atuin.sh | bash -s -- --non-interactive
    fi

    if [[ -x "${HOME}/.atuin/bin/atuin" && ! -e "${HOME}/.local/bin/atuin" ]]; then
      mkdir -p "${HOME}/.local/bin"
      ln -sfn "${HOME}/.atuin/bin/atuin" "${HOME}/.local/bin/atuin"
    fi
    export PATH="${HOME}/.local/bin:${HOME}/.atuin/bin:${PATH}"
    eval "$(mise activate bash)" 2>/dev/null || true

    if have atuin; then
      ok "atuin installed"
    else
      warn "atuin not on PATH after install"
      return 0
    fi
  fi

  # Sensible defaults after binary is present (safe to re-run)
  _atuin_post_install_defaults
}

_atuin_post_install_defaults() {
  export PATH="${HOME}/.local/bin:${HOME}/.atuin/bin:${PATH}"
  if ! have atuin; then
    return 0
  fi

  # Import existing shell history once (local only — no cloud account)
  # atuin stores whether DB has data; import auto is idempotent-ish but can be noisy.
  # Use a marker so we only auto-import on first bootstrap of this machine.
  local marker="${HOME}/.local/state/exe-bootstrap/atuin-import.done"
  mkdir -p "$(dirname "$marker")"
  if [[ -f "$marker" ]]; then
    skip "atuin history import already done (marker present)"
  else
    log "atuin: importing existing shell history (local; no sync account)"
    if atuin import auto 2>/dev/null; then
      ok "atuin import auto completed"
    else
      warn "atuin import auto skipped/failed — run later: atuin import auto"
    fi
    touch "$marker"
  fi

  # Optional: ensure a default config exists without overwriting user edits
  local cfg="${HOME}/.config/atuin/config.toml"
  if [[ ! -f "$cfg" ]]; then
    mkdir -p "$(dirname "$cfg")"
    if atuin default-config >"$cfg" 2>/dev/null; then
      ok "wrote default atuin config: $cfg"
    fi
  else
    skip "atuin config already exists"
  fi

  ok "atuin ready — shell hook is in ~/.zshrc; cloud sync later: atuin login / atuin register"
}
