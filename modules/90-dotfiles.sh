#!/usr/bin/env bash
# Link managed dotfiles into $HOME

run() {
  link_file "${BOOTSTRAP_ROOT}/home/.zshrc" "${HOME}/.zshrc"
  link_file "${BOOTSTRAP_ROOT}/home/aliases.zsh" "${HOME}/.aliases.zsh"
  link_file "${BOOTSTRAP_ROOT}/home/.gitconfig" "${HOME}/.gitconfig"

  mkdir -p "${HOME}/.config"
  link_file "${BOOTSTRAP_ROOT}/home/starship.toml" "${HOME}/.config/starship.toml"

  # Ensure zsh is available message
  if [[ ! -f "${HOME}/.zshrc.local" ]]; then
    cat >"${HOME}/.zshrc.local" <<'EOF'
# Local overrides (not managed by exe-bootstrap). Safe to edit.
# export SOME_MACHINE_SPECIFIC=1
EOF
    ok "created empty ~/.zshrc.local for personal overrides"
  else
    skip "~/.zshrc.local exists"
  fi

  ok "dotfiles linked"
}
