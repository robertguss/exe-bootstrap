#!/usr/bin/env bash
# Neovim + stock LazyVim starter

run() {
  export PATH="${HOME}/.local/bin:${PATH}"

  if have nvim; then
    skip "nvim present: $(nvim --version | head -1)"
  else
    log "installing neovim"
    # Prefer apt for simplicity on Ubuntu 24.04; fall back to appimage-ish via mise
    if apt_install neovim; then
      ok "neovim via apt"
    elif have mise; then
      mise install neovim && mise use -g neovim && ok "neovim via mise"
    else
      err "could not install neovim"
      return 1
    fi
  fi

  local nvim_cfg="${HOME}/.config/nvim"
  if [[ -d "$nvim_cfg" ]]; then
    if [[ -d "${nvim_cfg}/.git" ]] && git -C "$nvim_cfg" remote get-url origin 2>/dev/null | grep -qi lazyvim; then
      skip "LazyVim config already present"
      return 0
    fi
    if [[ -f "${nvim_cfg}/lazy-lock.json" ]] || [[ -d "${nvim_cfg}/lua/config" ]]; then
      skip "nvim config looks like LazyVim/custom — leaving alone"
      return 0
    fi
    warn "existing ~/.config/nvim — backing up"
    mv "$nvim_cfg" "${nvim_cfg}.bak.$(date +%s)"
  fi

  log "cloning LazyVim starter"
  git clone --depth=1 https://github.com/LazyVim/starter "$nvim_cfg"
  rm -rf "${nvim_cfg}/.git"
  ok "LazyVim starter at $nvim_cfg (first nvim launch will install plugins)"
}
