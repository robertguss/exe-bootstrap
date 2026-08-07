# ~/.zshrc — managed by exe-bootstrap (module 90-dotfiles)
# Personal extras: put them in ~/.zshrc.local (sourced at end if present).

export ZSH="${HOME}/.oh-my-zsh"

# Prompt is Starship (loaded below). Keep OMZ theme empty to avoid double prompts.
ZSH_THEME=""

# Optional: auto-activate Python venv helpers if your tooling uses this
export PYTHON_AUTO_VRUN=true

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "oh-my-zsh not found at $ZSH — run ~/Projects/exe-bootstrap/install" >&2
fi

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# PATH: user bins
export PATH="${HOME}/bin:${HOME}/.local/bin:${HOME}/go/bin:${PATH}"
# Grok Build
export PATH="${HOME}/.grok/bin:${PATH}"

# mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
elif [[ -x "${HOME}/.local/bin/mise" ]]; then
  eval "$("${HOME}/.local/bin/mise" activate zsh)"
fi

# fnox
if command -v fnox >/dev/null 2>&1; then
  eval "$(fnox activate zsh)"
fi
if [[ -f "${HOME}/.config/fnox/age.txt" ]]; then
  # Prefer secret key line; fall back to whole-file parse
  _fnox_key="$(grep -E '^AGE-SECRET-KEY-' "${HOME}/.config/fnox/age.txt" 2>/dev/null | head -1 || true)"
  if [[ -n "${_fnox_key}" ]]; then
    export FNOX_AGE_KEY="${_fnox_key}"
  fi
  unset _fnox_key
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# atuin (history) — after other binds
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# starship prompt (last wins)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Grok completions if present
if [[ -d "${HOME}/.grok/completions/zsh" ]]; then
  fpath=("${HOME}/.grok/completions/zsh" $fpath)
fi

# Aliases from bootstrap
[[ -f "${HOME}/.aliases.zsh" ]] && source "${HOME}/.aliases.zsh"

# Machine-local overrides (not managed)
[[ -f "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"
