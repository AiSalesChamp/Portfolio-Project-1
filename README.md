# massCode AppImage installer

A small, idempotent installer for the official [massCode](https://github.com/massCodeIO/massCode)
desktop app (snippets, notes, HTTP client) on Debian/Ubuntu Linux.

massCode is a **local-first** app — your data lives as plain Markdown files in
a vault on disk.

## Usage

Run on **your local machine** (not in a remote/cloud container — the app has a
GUI and stores data on the machine it runs on):

```bash
bash install.sh
```

The script:

1. Installs prerequisites (`libfuse2`/`libfuse2t64`, `wget`) via `apt`.
2. Downloads `massCode-5.5.0.AppImage` to `~/Applications` (skipped if present).
3. Verifies the SHA-256 checksum before continuing.
4. Marks it executable.
5. Creates a `masscode` symlink in `~/.local/bin` and a desktop menu entry.

Then launch from your app menu or run `masscode`. On first launch, create or
open a vault, e.g. `~/Documents/massCode-vault`.

## Not the same as these

From shell history — these are unrelated and should **not** be used:

| Command | What it actually is |
|---------|---------------------|
| `pip install masscode-py` | Unrelated Python CLI |
| `npm install -g masscode` | Unrelated npm package |
| `sudo snap install masscode` | Snap package, not the official v5 build |

## Cleanup of conflicting installs

If `masscode` in your terminal launches the wrong tool:

```bash
pip3 uninstall masscode-py 2>/dev/null || true
npm uninstall -g masscode 2>/dev/null || true
sudo snap remove masscode 2>/dev/null || true
```

Then re-run `bash install.sh` to restore the symlink to the AppImage.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `dlopen(): error loading libfuse` | Install `libfuse2` (or `libfuse2t64` on Ubuntu 24.04+); `sudo apt install fuse3` as fallback |
| AppImage won't start / no window | Run from a terminal and read the errors; confirm it is executable |
| `masscode --help` shows a Python CLI | Wrong binary on PATH — see Cleanup above |
| Blank window on Wayland | `GDK_BACKEND=x11 ~/Applications/massCode-5.5.0.AppImage` |
| Upgrade later | Edit `VERSION`/`SHA256` in `install.sh` and re-run |

Docs: <https://masscode.io/documentation/>
