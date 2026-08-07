#!/usr/bin/env bash
# Modern CLI tools via mise and apt fallbacks

run() {
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! have mise; then
    err "mise required"
    return 1
  fi
  eval "$(mise activate bash)" 2>/dev/null || true

  local pkg
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    pkg="${pkg%%#*}"
    pkg="$(echo "$pkg" | xargs)" # trim
    [[ -z "$pkg" ]] && continue

    if mise install "$pkg" 2>/dev/null; then
      mise use -g "$pkg" 2>/dev/null || true
      ok "mise: $pkg"
    else
      warn "mise could not install $pkg — will try apt if known"
    fi
  done <"${BOOTSTRAP_ROOT}/config/packages.cli"

  # yq: try mise then apt
  if ! have yq; then
    mise install yq 2>/dev/null && mise use -g yq 2>/dev/null || apt_install yq || warn "yq missing"
  else
    skip "yq present"
  fi

  # Ensure zoxide / starship / bat etc. are global
  for t in ripgrep fd fzf bat eza zoxide starship jq; do
    mise use -g "$t" 2>/dev/null || true
  done

  # fzf keybindings if installed via apt as fallback
  if ! have fzf; then
    apt_install fzf || true
  fi
  if ! have bat; then
    apt_install bat || true
    # Debian packages bat as batcat
    if have batcat && [[ ! -e "${HOME}/.local/bin/bat" ]]; then
      ln -sfn "$(command -v batcat)" "${HOME}/.local/bin/bat"
    fi
  fi
  if ! have rg; then
    apt_install ripgrep || true
  fi
  if ! have fd && ! have fdfind; then
    apt_install fd-find || true
    if have fdfind && [[ ! -e "${HOME}/.local/bin/fd" ]]; then
      ln -sfn "$(command -v fdfind)" "${HOME}/.local/bin/fd"
    fi
  fi

  ok "cli tools module finished"
}
