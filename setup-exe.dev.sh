#!/usr/bin/env bash
# Optional thin first-boot script for: ssh exe.dev new --setup-script ...
# Not registered as default — run manually or pipe when creating a VM.
#
# This script only clones the repo and runs install. Keep it small
# (exe.dev setup-script size limits). Prefer cloning after SSH for control.
set -euo pipefail

REPO_URL="${EXE_BOOTSTRAP_REPO:-https://github.com/robertguss/exe-bootstrap.git}"
DEST="${EXE_BOOTSTRAP_DIR:-${HOME}/exe-bootstrap}"

if [[ ! -d "$DEST/.git" ]]; then
  git clone "$REPO_URL" "$DEST"
else
  git -C "$DEST" pull --ff-only || true
fi

exec "$DEST/install"
