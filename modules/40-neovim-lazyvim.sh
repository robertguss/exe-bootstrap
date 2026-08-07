#!/usr/bin/env bash
# Neovim (via mise) + stock LazyVim starter
#
# LazyVim requires Neovim >= 0.11.2. Ubuntu's apt package is often older
# (e.g. 0.9.x on 24.04), so we always install via mise and put a
# ~/.local/bin/nvim symlink ahead of the system binary.

# Minimum version for LazyVim (major.minor.patch)
NVIM_MIN_VERSION="0.11.2"

# Return 0 if version $1 >= version $2 (semver-ish, numeric dots only).
_version_ge() {
  local have="$1" need="$2"
  [[ -n "$have" && -n "$need" ]] || return 1
  printf '%s\n%s\n' "$need" "$have" | sort -C -V
}

# Print nvim version as X.Y.Z from `nvim --version` first line.
_nvim_version() {
  local bin="${1:-nvim}"
  "$bin" --version 2>/dev/null | head -1 | sed -n 's/.*v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p'
}

# True if the nvim on PATH is new enough for LazyVim.
_nvim_ok() {
  local ver
  have nvim || return 1
  ver="$(_nvim_version nvim)"
  _version_ge "$ver" "$NVIM_MIN_VERSION"
}

# Symlink mise's nvim into ~/.local/bin so it wins over /usr/bin/nvim
# even in shells that have not run `mise activate` yet.
_link_mise_nvim() {
  local real dest="${HOME}/.local/bin/nvim"
  real="$(mise which nvim 2>/dev/null || true)"
  if [[ -z "$real" || ! -x "$real" ]]; then
    # Fallback: conventional mise layout
    if [[ -x "${HOME}/.local/share/mise/installs/neovim/latest/bin/nvim" ]]; then
      real="${HOME}/.local/share/mise/installs/neovim/latest/bin/nvim"
    else
      return 1
    fi
  fi
  mkdir -p "${HOME}/.local/bin"
  if [[ -L "$dest" || ! -e "$dest" ]]; then
    ln -sfn "$real" "$dest"
  elif [[ -e "$dest" ]]; then
    # Unexpected regular file — back up then link
    local bak="${dest}.bak.$(date +%s)"
    warn "backing up $dest -> $bak"
    mv "$dest" "$bak"
    ln -sfn "$real" "$dest"
  fi
  ok "linked $dest -> $real"
}

run() {
  export PATH="${HOME}/.local/bin:${PATH}"

  if ! have mise && [[ -x "${HOME}/.local/bin/mise" ]]; then
    # shellcheck disable=SC2139
    mise() { "${HOME}/.local/bin/mise" "$@"; }
  fi
  if ! have mise; then
    err "mise required for neovim (run module 20-mise first)"
    return 1
  fi
  eval "$(mise activate bash)" 2>/dev/null || true

  # Prefer a LazyVim-capable nvim from mise; never settle for an old apt binary.
  if _nvim_ok && command -v nvim | grep -qE "${HOME}/.local|mise"; then
    skip "nvim present and new enough: $(nvim --version | head -1) ($(command -v nvim))"
  else
    if have nvim; then
      warn "system/old nvim is $(nvim --version | head -1) at $(command -v nvim) — installing via mise (>= ${NVIM_MIN_VERSION})"
    else
      log "installing neovim via mise (>= ${NVIM_MIN_VERSION})"
    fi

    # Keep global mise.toml in sync (config/mise.toml also lists neovim).
    mise use -g neovim@latest 2>/dev/null || mise use -g neovim || true
    mise install neovim || {
      err "mise install neovim failed"
      return 1
    }
    mise reshim 2>/dev/null || true
    eval "$(mise activate bash)" 2>/dev/null || true

    _link_mise_nvim || {
      err "could not link mise nvim into ~/.local/bin"
      return 1
    }

    # Prefer user bin for the rest of this module / shell session
    export PATH="${HOME}/.local/bin:${PATH}"
    hash -r 2>/dev/null || true

    if ! _nvim_ok; then
      err "nvim still too old or missing after mise install: $(command -v nvim 2>/dev/null || echo none) $(_nvim_version nvim 2>/dev/null || true)"
      return 1
    fi
    ok "neovim via mise: $(nvim --version | head -1) ($(command -v nvim))"
  fi

  # Always refresh the symlink so upgrades stay ahead of /usr/bin/nvim
  _link_mise_nvim 2>/dev/null || true
  export PATH="${HOME}/.local/bin:${PATH}"
  hash -r 2>/dev/null || true

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
