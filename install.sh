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
EXTRACT_DIR="${APP_DIR}/massCode-${VERSION}.AppDir"
BIN_DIR="${HOME}/.local/bin"
LAUNCHER="${BIN_DIR}/masscode"
DESKTOP_DIR="${HOME}/.local/share/applications"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }

if [[ "${EUID}" -eq 0 ]]; then
  warn "Running as root. This installs into root's home (${HOME}); run as your normal user instead."
fi

# --- Step 1: prerequisites -------------------------------------------------
# Note: this installer extracts the AppImage and runs it WITHOUT FUSE
# (see Step 3b), so FUSE is no longer required. libfuse2 is still installed
# as a best effort because it lets you run the raw .AppImage directly too.
if command -v apt-get >/dev/null 2>&1; then
  info "Installing prerequisites (wget, libfuse2) via apt..."
  sudo apt-get update -y
  sudo apt-get install -y wget
  # libfuse2 is renamed libfuse2t64 on Ubuntu 24.04+; try the new name first.
  sudo apt-get install -y libfuse2t64 2>/dev/null \
    || sudo apt-get install -y libfuse2 2>/dev/null \
    || warn "Could not install libfuse2/libfuse2t64 (not fatal: the app is run from an extracted copy that does not need FUSE)."
else
  warn "apt-get not found (non-Debian distro?). 'wget' is required; install it with your package manager. FUSE is NOT required by this installer."
fi

if ! command -v wget >/dev/null 2>&1; then
  warn "wget is not installed and could not be installed automatically. Install it and re-run."
  exit 1
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

# --- Step 3b: extract (so we never depend on FUSE at runtime) -------------
# Ubuntu 24.04+ ships libfuse2t64, and AppImages frequently still fail with
# "dlopen(): error loading libfuse" / "AppImages require FUSE to run".
# `--appimage-extract` is handled by the AppImage runtime itself and does
# NOT use FUSE, so extracting once and running the extracted app sidesteps
# the whole problem.
if [[ -x "${EXTRACT_DIR}/AppRun" ]]; then
  info "Extracted app already present at ${EXTRACT_DIR}, skipping extraction."
else
  info "Extracting AppImage (no FUSE needed)..."
  workdir="$(mktemp -d "${APP_DIR}/.extract.XXXXXX")"
  (
    cd "${workdir}"
    "${APP_PATH}" --appimage-extract >/dev/null
  )
  rm -rf "${EXTRACT_DIR}"
  mv "${workdir}/squashfs-root" "${EXTRACT_DIR}"
  rmdir "${workdir}" 2>/dev/null || rm -rf "${workdir}"
  info "Extracted to ${EXTRACT_DIR}"
fi

# --- Step 4: launcher ------------------------------------------------------
# A wrapper script (not a symlink) so we can handle the Ubuntu 24.04 Electron
# sandbox case: chrome-sandbox must be setuid-root, which it is not in a
# user-extracted copy. If it is not correctly configured, fall back to
# --no-sandbox so the app still starts instead of fatally aborting.
mkdir -p "${BIN_DIR}"
cat > "${LAUNCHER}" <<EOF
#!/usr/bin/env bash
# Launch massCode from the extracted AppDir (no FUSE required).
set -euo pipefail
APPDIR="${EXTRACT_DIR}"
sandbox="\${APPDIR}/chrome-sandbox"
args=()
if [[ -e "\${sandbox}" ]]; then
  # Electron's SUID sandbox needs chrome-sandbox owned by root with mode 4755.
  if [[ "\$(stat -c '%u' "\${sandbox}" 2>/dev/null)" != "0" ]] \\
     || [[ "\$(stat -c '%a' "\${sandbox}" 2>/dev/null)" != "4755" ]]; then
    args+=(--no-sandbox)
  fi
fi
exec "\${APPDIR}/AppRun" "\${args[@]}" "\$@"
EOF
chmod +x "${LAUNCHER}"
info "Created launcher ${LAUNCHER}"

if ! grep -q '.local/bin' "${HOME}/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
  info "Added ~/.local/bin to PATH in ~/.bashrc (open a new shell or 'source ~/.bashrc')."
fi

# Use the AppDir's own icon if present, otherwise fall back to a theme name.
icon="masscode"
if [[ -f "${EXTRACT_DIR}/.DirIcon" ]]; then
  icon="${EXTRACT_DIR}/.DirIcon"
fi

mkdir -p "${DESKTOP_DIR}"
cat > "${DESKTOP_DIR}/masscode.desktop" <<EOF
[Desktop Entry]
Name=massCode
Comment=Developer workspace (snippets, notes, HTTP)
Exec=${LAUNCHER}
Icon=${icon}
Terminal=false
Type=Application
Categories=Development;TextEditor;
EOF
info "Created desktop entry ${DESKTOP_DIR}/masscode.desktop"

cat <<EOF

$(info "Done.")
massCode ${VERSION} is installed:
  AppImage:  ${APP_PATH}
  Extracted: ${EXTRACT_DIR}  (run from here, no FUSE needed)

Launch it from your application menu, or run:
  masscode

On first launch, create or open a vault (a folder where your snippets/notes
are stored as Markdown), e.g. ~/Documents/massCode-vault.

If you previously installed conflicting tools, see "Cleanup" in README.md.
EOF
