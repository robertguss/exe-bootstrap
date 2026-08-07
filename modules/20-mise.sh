#!/usr/bin/env bash
# Install mise and global config

run() {
  if have mise; then
    skip "mise already on PATH: $(mise --version 2>/dev/null | head -1)"
  elif [[ -x "${HOME}/.local/bin/mise" ]]; then
    skip "mise at ~/.local/bin/mise"
  else
    log "installing mise"
    curl -fsSL https://mise.run | sh
    ok "mise installed"
  fi

  # Ensure mise is usable in this script
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! have mise && [[ -x "${HOME}/.local/bin/mise" ]]; then
    # shellcheck disable=SC2139
    mise() { "${HOME}/.local/bin/mise" "$@"; }
  fi

  mkdir -p "${HOME}/.config/mise"
  link_file "${BOOTSTRAP_ROOT}/config/mise.toml" "${HOME}/.config/mise/config.toml"

  log "mise install (global tools — may take a while)"
  mise trust "${HOME}/.config/mise/config.toml" 2>/dev/null || true
  mise install -y || mise install || warn "mise install had errors; re-run later"
  ok "mise tools installed"
}
