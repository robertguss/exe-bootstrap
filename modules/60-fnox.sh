#!/usr/bin/env bash
# fnox + fresh age key generation

run() {
  export PATH="${HOME}/.local/bin:${PATH}"
  eval "$(mise activate bash)" 2>/dev/null || true

  if have fnox; then
    skip "fnox present: $(fnox --version 2>/dev/null | head -1 || echo yes)"
  else
    log "installing fnox via mise"
    if mise use -g fnox@latest 2>/dev/null || (mise install fnox && mise use -g fnox); then
      ok "fnox installed"
    else
      warn "mise fnox failed — check https://fnox.jdx.dev/"
    fi
  fi

  mkdir -p "${HOME}/.config/fnox"
  chmod 700 "${HOME}/.config/fnox"

  local age_file="${HOME}/.config/fnox/age.txt"
  if [[ -f "$age_file" ]]; then
    skip "age key already exists at $age_file"
  else
    log "generating fresh age key"
    if have age-keygen; then
      age-keygen -o "$age_file" 2>/dev/null || age-keygen >"$age_file"
    elif have mise; then
      # age CLI via mise if available
      mise install age 2>/dev/null && mise use -g age 2>/dev/null || true
      if have age-keygen; then
        age-keygen -o "$age_file"
      fi
    fi

    if [[ ! -f "$age_file" ]]; then
      # Pure fallback: install age from apt
      apt_install age || true
      if have age-keygen; then
        age-keygen -o "$age_file"
      fi
    fi

    if [[ -f "$age_file" ]]; then
      chmod 600 "$age_file"
      ok "age key written to $age_file"
      warn "BACK UP this file offline — it decrypts your secrets"
      if grep -q "public key:" "$age_file" 2>/dev/null; then
        log "public key:"
        grep "public key:" "$age_file" || true
      fi
    else
      err "failed to generate age key — install 'age' and re-run module 60-fnox"
    fi
  fi

  # Example config into repo-local only (do not overwrite user fnox.toml)
  if [[ ! -f "${HOME}/.config/fnox/fnox.toml" ]]; then
    cp "${BOOTSTRAP_ROOT}/config/fnox.toml.example" "${HOME}/.config/fnox/fnox.toml.example"
    ok "wrote fnox.toml.example to ~/.config/fnox/"
  fi
}
