#!/usr/bin/env bash
# Lane C — Agent DX: ast-grep, gitleaks, git-absorb, difftastic
# Templates are in templates/ (copied/referenced by docs; not installed to $HOME)

run() {
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! have mise; then
    err "mise required"
    return 1
  fi
  eval "$(mise activate bash)" 2>/dev/null || true

  # Linux ships /bin/sg (shadow group) — do not treat it as ast-grep
  _have_ast_grep() {
    have ast-grep && return 0
    local p
    p="$(command -v sg 2>/dev/null || true)"
    [[ -n "$p" && "$p" != "/bin/sg" && "$p" != "/usr/bin/sg" ]] && return 0
    return 1
  }

  _mise_tool() {
    local name="$1"
    local pkg="${2:-$1}"
    if [[ "$name" == "ast-grep" ]] && _have_ast_grep; then
      skip "ast-grep present"
      return 0
    fi
    if [[ "$name" == "difftastic" ]] && have difft; then
      skip "difftastic (difft) present"
      return 0
    fi
    if [[ "$name" != "ast-grep" && "$name" != "difftastic" ]] && have "$name"; then
      skip "$name present"
      return 0
    fi
    log "installing $pkg via mise"
    if mise use -g "${pkg}@latest" 2>/dev/null || (mise install "$pkg" && mise use -g "$pkg"); then
      ok "mise: $pkg"
    else
      warn "could not install $pkg"
    fi
  }

  _mise_tool ast-grep ast-grep
  _mise_tool gitleaks gitleaks
  _mise_tool git-absorb "aqua:tummychow/git-absorb"
  _mise_tool difftastic difftastic

  mise reshim 2>/dev/null || true
  eval "$(mise activate bash)" 2>/dev/null || true
  hash -r 2>/dev/null || true

  _have_ast_grep && ok "ast-grep ready ($(command -v ast-grep 2>/dev/null || command -v sg))" || warn "ast-grep missing"
  have gitleaks && ok "gitleaks $(gitleaks version 2>/dev/null | head -1 || echo ok)" || warn "gitleaks missing"
  have git-absorb && ok "git-absorb ready" || warn "git-absorb missing"
  have difft && ok "difftastic (difft) ready" || warn "difft missing"

  if [[ -f "${BOOTSTRAP_ROOT}/templates/AGENTS.md" ]]; then
    ok "AGENTS.md template at templates/AGENTS.md"
  else
    warn "templates/AGENTS.md missing from bootstrap repo"
  fi
}
