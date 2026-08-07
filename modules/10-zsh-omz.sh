#!/usr/bin/env bash
# zsh + Oh My Zsh + plugins

run() {
  apt_install zsh

  # Default shell to zsh if not already
  local current zsh_path
  zsh_path="$(command -v zsh)"
  current="$(getent passwd "$USER" | cut -d: -f7 || true)"
  if [[ "$current" == "$zsh_path" ]]; then
    skip "default shell already zsh"
  else
    log "setting default shell to zsh"
    if chsh -s "$zsh_path" "$USER" 2>/dev/null; then
      ok "default shell -> zsh"
    elif need_sudo "chsh" && "${SUDO[@]}" chsh -s "$zsh_path" "$USER" 2>/dev/null; then
      ok "default shell -> zsh (via sudo)"
    else
      warn "could not chsh to zsh — run: sudo chsh -s $(command -v zsh) $USER"
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
