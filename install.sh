#!/usr/bin/env bash
#
# Install the official massCode desktop app (AppImage) on Debian/Ubuntu Linux.
#
# Run this on YOUR local machine (not in a remote/cloud container):
#
#   bash install.sh
#
# Re-running is safe: existing files are reused and the launcher is refreshed.

set -euo pipefail

VERSION="5.5.0"
ASSET="massCode-${VERSION}.AppImage"
URL="https://github.com/massCodeIO/massCode/releases/download/v${VERSION}/${ASSET}"
SHA256="38e288af1f70cfdb1adcd32d23807540e268c1211c1a0b7cb3d6bf449e85dc8c"

APP_DIR="${HOME}/Applications"
APP_PATH="${APP_DIR}/${ASSET}"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }

if [[ "${EUID}" -eq 0 ]]; then
  warn "Running as root. This installs into root's home (${HOME}); run as your normal user instead."
fi

# --- Step 1: prerequisites -------------------------------------------------
if command -v apt-get >/dev/null 2>&1; then
  info "Installing prerequisites (libfuse2, wget) via apt..."
  sudo apt-get update -y
  # libfuse2 is named libfuse2t64 on newer Ubuntu (24.04+); try both.
  sudo apt-get install -y wget
  sudo apt-get install -y libfuse2 2>/dev/null \
    || sudo apt-get install -y libfuse2t64 2>/dev/null \
    || warn "Could not install libfuse2/libfuse2t64; if the app fails with a FUSE error, install it manually (or 'sudo apt-get install -y fuse3')."
else
  warn "apt-get not found. Install FUSE (libfuse2) and wget with your distro's package manager before continuing."
fi

# --- Step 2: download ------------------------------------------------------
mkdir -p "${APP_DIR}"
if [[ -f "${APP_PATH}" ]]; then
  info "${ASSET} already present, skipping download."
else
  info "Downloading ${ASSET} (~171 MB)..."
  wget -O "${APP_PATH}" "${URL}"
fi

# --- Step 2b: integrity check ---------------------------------------------
if command -v sha256sum >/dev/null 2>&1; then
  info "Verifying SHA-256 checksum..."
  actual="$(sha256sum "${APP_PATH}" | awk '{print $1}')"
  if [[ "${actual}" != "${SHA256}" ]]; then
    warn "Checksum mismatch!"
    warn "  expected: ${SHA256}"
    warn "  actual:   ${actual}"
    warn "Refusing to continue. Delete ${APP_PATH} and re-run, or verify the release."
    exit 1
  fi
  info "Checksum OK."
else
  warn "sha256sum not available; skipping integrity check."
fi

# --- Step 3: make executable ----------------------------------------------
chmod +x "${APP_PATH}"

# --- Step 4: launcher ------------------------------------------------------
mkdir -p "${BIN_DIR}"
ln -sf "${APP_PATH}" "${BIN_DIR}/masscode"
info "Symlinked ${BIN_DIR}/masscode -> ${APP_PATH}"

if ! grep -q '.local/bin' "${HOME}/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
  info "Added ~/.local/bin to PATH in ~/.bashrc (open a new shell or 'source ~/.bashrc')."
fi

mkdir -p "${DESKTOP_DIR}"
cat > "${DESKTOP_DIR}/masscode.desktop" <<EOF
[Desktop Entry]
Name=massCode
Comment=Developer workspace (snippets, notes, HTTP)
Exec=${APP_PATH}
Icon=masscode
Terminal=false
Type=Application
Categories=Development;TextEditor;
EOF
info "Created desktop entry ${DESKTOP_DIR}/masscode.desktop"

cat <<EOF

$(info "Done.")
massCode ${VERSION} is installed at:
  ${APP_PATH}

Launch it from your application menu, or run:
  masscode

On first launch, create or open a vault (a folder where your snippets/notes
are stored as Markdown), e.g. ~/Documents/massCode-vault.

If you previously installed conflicting tools, see "Cleanup" in README.md.
EOF
