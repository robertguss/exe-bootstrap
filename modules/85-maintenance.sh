#!/usr/bin/env bash
# Link mr-boxington config, update/cleanup scripts, and enable the systemd cleanup timer

run() {
  mkdir -p "${HOME}/.config/mbx" "${HOME}/.local/bin" "${HOME}/.config/systemd/user"

  link_file "${BOOTSTRAP_ROOT}/config/mbx.toml" "${HOME}/.config/mbx/config.toml"

  chmod +x "${BOOTSTRAP_ROOT}/scripts/dev-box-update" "${BOOTSTRAP_ROOT}/scripts/dev-box-cleanup"
  link_file "${BOOTSTRAP_ROOT}/scripts/dev-box-update" "${HOME}/.local/bin/dev-box-update"
  link_file "${BOOTSTRAP_ROOT}/scripts/dev-box-cleanup" "${HOME}/.local/bin/dev-box-cleanup"

  link_file "${BOOTSTRAP_ROOT}/config/systemd/dev-box-cleanup.service" "${HOME}/.config/systemd/user/dev-box-cleanup.service"
  link_file "${BOOTSTRAP_ROOT}/config/systemd/dev-box-cleanup.timer" "${HOME}/.config/systemd/user/dev-box-cleanup.timer"

  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  if have systemctl && systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user daemon-reload
    systemctl --user enable --now dev-box-cleanup.timer
    ok "dev-box-cleanup.timer enabled"
  else
    warn "systemd --user session unavailable; skipping timer enable (run dev-box-cleanup manually or enable later)"
  fi
}
