#!/usr/bin/env bash
# GitHub CLI, lazygit, delta

run() {
  export PATH="${HOME}/.local/bin:${PATH}"
  eval "$(mise activate bash)" 2>/dev/null || true

  # gh
  if have gh; then
    skip "gh already installed: $(gh --version | head -1)"
  else
    log "installing GitHub CLI"
    if mise install gh 2>/dev/null && mise use -g gh; then
      ok "gh via mise"
    else
      # Official apt repo
      need_sudo "gh"
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | "${SUDO[@]}" dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
      "${SUDO[@]}" chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | "${SUDO[@]}" tee /etc/apt/sources.list.d/github-cli.list >/dev/null
      "${SUDO[@]}" apt-get update -qq
      DEBIAN_FRONTEND=noninteractive "${SUDO[@]}" apt-get install -y -qq gh
      ok "gh via apt"
    fi
  fi

  # lazygit
  if have lazygit; then
    skip "lazygit present"
  else
    mise install lazygit 2>/dev/null && mise use -g lazygit && ok "lazygit" || warn "lazygit failed"
  fi

  # delta
  if have delta; then
    skip "delta present"
  else
    mise install delta 2>/dev/null && mise use -g delta && ok "delta" || {
      apt_install git-delta 2>/dev/null || warn "delta failed"
    }
  fi
}
