#!/usr/bin/env bash
# zsh + Oh My Zsh + plugins

run() {
  apt_install zsh

  # Default shell to zsh if not already.
  # IMPORTANT: never run interactive chsh/sudo — they hang ./install waiting for a password.
  local current zsh_path changed=0
  zsh_path="$(command -v zsh)"
  current="$(getent passwd "$USER" | cut -d: -f7 || true)"
  if [[ "$current" == "$zsh_path" ]]; then
    skip "default shell already zsh"
  else
    log "setting default shell to zsh (non-interactive only)"
    # Passwordless sudo only (sudo -n never prompts)
    if sudo -n true 2>/dev/null; then
      if sudo -n chsh -s "$zsh_path" "$USER" 2>/dev/null \
        || sudo -n usermod -s "$zsh_path" "$USER" 2>/dev/null; then
        ok "default shell -> zsh (sudo -n)"
        changed=1
      fi
    fi
    # Last resort: chsh with closed stdin + short timeout (still no password prompt usable)
    if [[ "$changed" -eq 0 ]] && have timeout; then
      if timeout 3s chsh -s "$zsh_path" "$USER" </dev/null >/dev/null 2>&1; then
        ok "default shell -> zsh"
        changed=1
      fi
    fi
    if [[ "$changed" -eq 0 ]]; then
      warn "could not change login shell non-interactively (install continues)"
      warn "after install, run:  sudo chsh -s $(command -v zsh) \$USER  &&  exec zsh"
    fi
  fi

  export ZSH="${ZSH:-${HOME}/.oh-my-zsh}"
  if [[ ! -d "$ZSH" ]]; then
    log "installing Oh My Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "Oh My Zsh installed"
  else
    skip "Oh My Zsh already at $ZSH"
  fi

  local custom="${ZSH_CUSTOM:-${ZSH}/custom}/plugins"
  mkdir -p "$custom"

  _clone_plugin() {
    local name="$1"
    local url="$2"
    local dest="${custom}/${name}"
    if [[ -d "$dest/.git" ]]; then
      skip "plugin $name present"
      git -C "$dest" pull --ff-only -q 2>/dev/null || true
    else
      log "cloning plugin $name"
      git clone --depth=1 "$url" "$dest"
      ok "plugin $name"
    fi
  }

  _clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
  _clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
}
