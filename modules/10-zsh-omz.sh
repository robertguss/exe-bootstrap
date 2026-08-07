#!/usr/bin/env bash
# zsh + Oh My Zsh + plugins
# Goal: new installs always default to zsh (passwd login shell + $SHELL + interactive bash).

run() {
  apt_install zsh

  local zsh_path current changed=0
  zsh_path="$(command -v zsh)"
  if [[ -z "$zsh_path" || ! -x "$zsh_path" ]]; then
    err "zsh not found on PATH after apt install"
    return 1
  fi
  # Prefer /bin/zsh when it is the same binary (common on Ubuntu; matches chsh norms).
  if [[ -x /bin/zsh ]] && [[ "$(readlink -f /bin/zsh 2>/dev/null || true)" == "$(readlink -f "$zsh_path" 2>/dev/null || true)" ]]; then
    zsh_path="/bin/zsh"
  fi

  # Ensure zsh is a valid login shell entry (chsh requires this).
  if [[ -f /etc/shells ]] && ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    if sudo -n true 2>/dev/null; then
      log "adding $zsh_path to /etc/shells"
      printf '%s\n' "$zsh_path" | sudo -n tee -a /etc/shells >/dev/null
      ok "registered $zsh_path in /etc/shells"
    else
      warn "$zsh_path not listed in /etc/shells (chsh may fail without sudo)"
    fi
  fi

  # Default shell to zsh if not already.
  # IMPORTANT: never run interactive chsh/sudo — they hang ./install waiting for a password.
  current="$(getent passwd "$USER" | cut -d: -f7 || true)"
  if [[ "$current" == "$zsh_path" || "$current" == *"/zsh" ]]; then
    # Also accept /usr/bin/zsh vs /bin/zsh when both exist as the same shell family.
    if [[ "$current" == "$zsh_path" ]]; then
      skip "default shell already zsh ($current)"
    else
      # Normalize passwd entry to our preferred path when safe.
      log "login shell is already zsh ($current); normalizing to $zsh_path if possible"
      if sudo -n true 2>/dev/null; then
        if sudo -n chsh -s "$zsh_path" "$USER" 2>/dev/null \
          || sudo -n usermod -s "$zsh_path" "$USER" 2>/dev/null; then
          ok "default shell normalized -> $zsh_path"
          changed=1
        else
          skip "default shell already zsh ($current)"
        fi
      else
        skip "default shell already zsh ($current)"
      fi
    fi
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

  # chsh only updates the passwd DB for *new* logins. Export SHELL now so the rest of
  # install (and any daemons started from this process tree, e.g. herdr) inherit zsh.
  export SHELL="$zsh_path"
  ok "SHELL=$SHELL for this install process and children"

  # Interactive bash -> zsh bridge.
  # After chsh, many tools still spawn $SHELL which may remain /bin/bash in long-lived
  # parents (install shell, herdr server). Switching interactive bash to zsh closes that gap.
  # Opt out: EXE_BOOTSTRAP_NO_ZSH=1
  ensure_block "${HOME}/.bashrc" "exe-bootstrap-zsh-default" "$(cat <<'EOF'
# Prefer zsh for interactive bash when zsh is the login shell.
# Fixes tools that spawn $SHELL while SHELL is still /bin/bash after chsh (e.g. herdr panes).
# Opt out for a single bash session: EXE_BOOTSTRAP_NO_ZSH=1 bash
if [[ -n "${BASH_VERSION:-}" && $- == *i* && -z "${EXE_BOOTSTRAP_NO_ZSH:-}" ]]; then
  _eb_zsh="$(command -v zsh 2>/dev/null || true)"
  _eb_login="$(getent passwd "${USER:-$(id -un)}" 2>/dev/null | cut -d: -f7 || true)"
  if [[ -n "$_eb_zsh" && -x "$_eb_zsh" && "$_eb_login" == *zsh* ]]; then
    export SHELL="$_eb_zsh"
    # Replace this bash with zsh on the same TTY/cwd (non-login: ~/.zshrc is enough).
    exec "$_eb_zsh"
  fi
  unset _eb_zsh _eb_login
fi
EOF
)"

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
