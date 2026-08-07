#!/usr/bin/env bash
# Base OS packages and essentials.

run() {
  apt_install \
    build-essential \
    ca-certificates \
    curl \
    wget \
    git \
    gnupg \
    software-properties-common \
    unzip \
    zip \
    tar \
    gzip \
    jq \
    htop \
    tree \
    tmux \
    trash-cli \
    openssh-client \
    xclip \
    locales

  # Ensure UTF-8 locale if possible
  if have locale-gen; then
    need_sudo locale-gen
    if ! locale -a 2>/dev/null | grep -qi 'en_US.utf8\|en_US.UTF-8'; then
      "${SUDO[@]}" locale-gen en_US.UTF-8 2>/dev/null || true
    fi
  fi

  mkdir -p "${HOME}/bin" "${HOME}/.local/bin" "${HOME}/Projects" "${HOME}/go/bin"
  ok "base directories ready"
}
