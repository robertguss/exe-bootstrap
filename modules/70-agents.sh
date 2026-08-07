#!/usr/bin/env bash
# Coding agents: Grok Build, Devin CLI; Pi/Shelley if missing

run() {
  export PATH="${HOME}/.local/bin:${HOME}/.grok/bin:${PATH}"

  # --- Grok Build (https://x.ai/build) ---
  if have grok; then
    skip "Grok Build present: $(grok --version 2>/dev/null | head -1 || echo yes)"
    grok update 2>/dev/null || true
  else
    log "installing Grok Build"
    curl -fsSL https://x.ai/cli/install.sh | bash
    ok "Grok Build installed"
  fi

  # --- Devin CLI ---
  if have devin; then
    skip "Devin CLI present"
  else
    log "installing Devin CLI"
    if curl -fsSL https://cli.devin.ai/install.sh | bash; then
      ok "Devin CLI installed (run 'devin' to auth)"
    else
      warn "Devin CLI install failed — see https://docs.devin.ai/cli"
    fi
  fi

  # --- Pi (exe.dev often preinstalls) ---
  if have pi; then
    skip "pi present"
  elif [[ -x "${HOME}/.local/bin/pi" ]]; then
    skip "pi at ~/.local/bin/pi"
  else
    warn "pi not found — on exeuntu it is usually preinstalled; skip or install manually"
  fi

  # Shelley / agent stubs are image-managed on exe.dev; do not force reinstall
  if [[ -d "${HOME}/.config/shelley" ]] || [[ -L "${HOME}/.claude/CLAUDE.md" ]]; then
    skip "shelley/agent config present"
  fi
}
