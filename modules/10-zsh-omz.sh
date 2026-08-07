#!/usr/bin/env bash
# zsh + Oh My Zsh + plugins

run() {
  apt_install zsh

  # Default shell to zsh if not already
  local current
  current="$(getent passwd "$USER" | cut -d: -f7 || true)"
  if [[ "$current" != "$(command -v zsh)" ]]; then
    if have chsh; then
      log "setting default shell to zsh"
      chsh -s "$(command -v zsh)" "$USER" 2>/dev/null || warn "chsh failed (set shell manually)"
    fi
  else
    skip "default shell already zsh"
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
