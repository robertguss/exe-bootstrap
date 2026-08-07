#!/usr/bin/env bash
# herdr — agent-aware terminal multiplexer

run() {
  export PATH="${HOME}/.local/bin:${PATH}"

  # herdr spawns new panes from $SHELL. Prefer the login/zsh path over a stale bash value
  # left over from the install process or a pre-chsh session.
  local zsh_path
  zsh_path="$(command -v zsh 2>/dev/null || true)"
  if [[ -n "$zsh_path" && -x "$zsh_path" ]]; then
    if [[ -x /bin/zsh ]] && [[ "$(readlink -f /bin/zsh 2>/dev/null || true)" == "$(readlink -f "$zsh_path" 2>/dev/null || true)" ]]; then
      zsh_path="/bin/zsh"
    fi
    export SHELL="$zsh_path"
    ok "herdr will inherit SHELL=$SHELL"
  fi

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
