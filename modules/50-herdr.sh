#!/usr/bin/env bash
# herdr — agent-aware terminal multiplexer

run() {
  export PATH="${HOME}/.local/bin:${PATH}"

  if have herdr; then
    skip "herdr already installed: $(herdr --version 2>/dev/null || echo yes)"
    # Optional self-update
    herdr update 2>/dev/null || true
    return 0
  fi

  log "installing herdr"
  curl -fsSL https://herdr.dev/install.sh | sh
  ok "herdr installed"
}
