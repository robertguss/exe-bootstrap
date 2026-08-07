#!/usr/bin/env bash
# Shared helpers for exe-bootstrap modules.
# shellcheck disable=SC2034

set -euo pipefail

BOOTSTRAP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export BOOTSTRAP_ROOT

# Colors (disable if not a TTY)
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_BLUE=$'\033[34m'
else
  C_RESET= C_BOLD= C_DIM= C_GREEN= C_YELLOW= C_RED= C_BLUE=
fi

log()  { printf '%s==>%s %s\n' "${C_BLUE}${C_BOLD}" "${C_RESET}" "$*"; }
ok()   { printf '%s[ok]%s %s\n' "${C_GREEN}" "${C_RESET}" "$*"; }
skip() { printf '%s[skip]%s %s\n' "${C_DIM}" "${C_RESET}" "$*"; }
warn() { printf '%s[warn]%s %s\n' "${C_YELLOW}" "${C_RESET}" "$*"; }
err()  { printf '%s[err]%s %s\n' "${C_RED}" "${C_RESET}" "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

need_sudo() {
  if [[ "$(id -u)" -eq 0 ]]; then
    SUDO=()
  elif have sudo; then
    SUDO=(sudo)
  else
    err "Need root or sudo for: $*"
    return 1
  fi
}

# Install apt packages if missing. Idempotent.
# Usage: apt_install pkg1 pkg2 ...
apt_install() {
  local missing=()
  local pkg
  for pkg in "$@"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
      skip "apt: $pkg already installed"
    else
      missing+=("$pkg")
    fi
  done
  if ((${#missing[@]} == 0)); then
    return 0
  fi
  need_sudo "apt install ${missing[*]}"
  log "apt install: ${missing[*]}"
  "${SUDO[@]}" apt-get update -qq
  DEBIAN_FRONTEND=noninteractive "${SUDO[@]}" apt-get install -y -qq "${missing[@]}"
  ok "apt installed: ${missing[*]}"
}

# Symlink src -> dest. Backs up existing non-symlink files once.
# Usage: link_file /path/to/repo/file ~/.file
link_file() {
  local src="$1"
  local dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      skip "link: $dest already -> $src"
      return 0
    fi
    warn "link: replacing symlink $dest ($current -> $src)"
    rm -f "$dest"
  elif [[ -e "$dest" ]]; then
    local bak="${dest}.bak.$(date +%s)"
    warn "link: backing up $dest -> $bak"
    mv "$dest" "$bak"
  fi

  ln -s "$src" "$dest"
  ok "linked $dest -> $src"
}

# Append a managed block to a file if not already present.
# Usage: ensure_block ~/.zshrc "exe-bootstrap" $'lines\nhere\n'
ensure_block() {
  local file="$1"
  local name="$2"
  local content="$3"
  local start="# >>> ${name} >>>"
  local end="# <<< ${name} <<<"

  mkdir -p "$(dirname "$file")"
  touch "$file"

  if grep -qF "$start" "$file" 2>/dev/null; then
    skip "block '${name}' already in $file"
    return 0
  fi

  {
    printf '\n%s\n' "$start"
    printf '%s\n' "$content"
    printf '%s\n' "$end"
  } >>"$file"
  ok "added block '${name}' to $file"
}

# Download URL to dest if dest missing or FORCE_DOWNLOAD=1
download() {
  local url="$1"
  local dest="$2"
  if [[ -f "$dest" && "${FORCE_DOWNLOAD:-0}" != "1" ]]; then
    skip "download exists: $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  log "download $url"
  curl -fsSL "$url" -o "$dest"
  ok "downloaded $dest"
}

is_enabled() {
  local module_id="$1"
  local modules_file="${BOOTSTRAP_ROOT}/config/modules.enabled"
  if [[ ! -f "$modules_file" ]]; then
    return 0
  fi
  # Empty lines and comments ignored; exact match on module basename without .sh
  grep -vE '^\s*(#|$)' "$modules_file" | grep -qxF "$module_id"
}

run_module() {
  local path="$1"
  local base
  base="$(basename "$path" .sh)"

  if ! is_enabled "$base"; then
    skip "module disabled: $base"
    return 0
  fi

  log "module: $base"
  # shellcheck source=/dev/null
  source "$path"
  if declare -f run >/dev/null; then
    run
    unset -f run
  else
    warn "module $base has no run() function"
  fi
  ok "module done: $base"
}
