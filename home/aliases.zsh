# Linux-safe aliases (ported from Mac .zshrc). Managed by exe-bootstrap.

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cl="clear"
alias sz="source ~/.zshrc"
alias sv="source .venv/bin/activate"

# Editors
alias nv="nvim"
alias ed="nvim"
alias zshconfig="nvim ~/.zshrc"

# Modern CLI replacements (require bat/eza from cli-tools module)
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi
if command -v eza >/dev/null 2>&1; then
  alias ls="eza -l -h -a"
fi

# trash-cli (safer rm)
if command -v trash-put >/dev/null 2>&1; then
  alias tr="trash-put"
  alias trash="trash-put"
elif command -v trash >/dev/null 2>&1; then
  alias tr="trash"
fi
alias rmnode="tr node_modules 2>/dev/null || trash-put node_modules"

# herdr / agents
alias hr="herdr"
alias grokcfg="nvim ~/.grok/config.toml"

# Docker / ops (Lane B)
command -v lazydocker >/dev/null 2>&1 && alias lzd="lazydocker"
command -v btm >/dev/null 2>&1 && alias bottom="btm"
command -v dust >/dev/null 2>&1 && alias duh="dust"   # human disk usage (avoid clobbering du)

# Agent DX (Lane C)
# Prefer `ast-grep` — on Linux /bin/sg is "shadow group", not ast-grep
if command -v ast-grep >/dev/null 2>&1; then
  alias agrep="ast-grep"
elif command -v sg >/dev/null 2>&1 && [[ "$(command -v sg)" != "/bin/sg" && "$(command -v sg)" != "/usr/bin/sg" ]]; then
  alias agrep="sg"
fi
command -v gitleaks >/dev/null 2>&1 && alias gls="gitleaks"
command -v difft >/dev/null 2>&1 && alias difftastic="difft"

# Node helpers
alias nr="npm run"
alias nd="npm run dev"
if command -v pnpm >/dev/null 2>&1; then
  alias p="pnpm"
  alias pd="pnpm dev"
fi

# Git helpers
alias ghb="gh browse"
alias gitclearcache="git rm -r --cached ."
# Destructive: delete local branches except main/master
alias gbcmain='git branch | grep -vE "^\*| main$" | xargs -r git branch -D'
alias gbcmaster='git branch | grep -vE "^\*| master$" | xargs -r git branch -D'

# fnox
alias fnoxpubkey='grep "public key:" ~/.config/fnox/age.txt 2>/dev/null || grep "public key:" ~/.config/fnox/age.txt'

# cookiecutter modern python (requires cookiecutter on PATH)
alias npp="cookiecutter https://github.com/robertguss/cookiecutter-modern-python-projects"

# Optional agent shims — only if binary exists
command -v claude >/dev/null 2>&1 && alias cc="claude"
command -v claude >/dev/null 2>&1 && alias ccd="claude --dangerously-skip-permissions"
command -v codex >/dev/null 2>&1 && alias cx="codex"
command -v codex >/dev/null 2>&1 && alias cxd="codex --yolo"
command -v opencode >/dev/null 2>&1 && alias oc="opencode"
command -v ollama >/dev/null 2>&1 && alias ol="ollama"
command -v devin >/dev/null 2>&1 && alias dv="devin"
