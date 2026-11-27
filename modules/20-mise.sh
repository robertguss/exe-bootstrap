#!/usr/bin/env bash
# Install mise, keep it current for native tool integrations, and configure shims + global config

_ver_ge() {
  printf '%s\n%s\n' "$2" "$1" | sort -C -V
}

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

  # Native mr_boxington integration requires mise >= 2026.9.2
  local mise_ver
  mise_ver="$(mise --version 2>/dev/null | awk '{print $1}' | head -n 1 || true)"
  if [[ -n "$mise_ver" ]] && ! _ver_ge "$mise_ver" "2026.9.2"; then
    log "updating mise ($mise_ver -> >= 2026.9.2 for mr_boxington)"
    mise self-update -y || warn "mise self-update failed"
  fi

  # Ensure non-interactive shells (agents, SSH commands) resolve mise shims (including mbx-wrapped cargo)
  local shims_line='export PATH="${HOME}/.local/share/mise/shims:${HOME}/.local/bin:${PATH}"'
  ensure_block "${HOME}/.zshenv" "exe-bootstrap-mise-shims" "$shims_line"
  ensure_block "${HOME}/.profile" "exe-bootstrap-mise-shims" "$shims_line"

  mkdir -p "${HOME}/.config/mise"
  link_file "${BOOTSTRAP_ROOT}/config/mise.toml" "${HOME}/.config/mise/config.toml"

  log "mise install (global tools — may take a while)"
  mise trust "${HOME}/.config/mise/config.toml" 2>/dev/null || true
  mise install -y || mise install || warn "mise install had errors; re-run later"
  ok "mise tools installed"
}
