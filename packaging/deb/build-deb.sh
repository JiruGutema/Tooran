#!/usr/bin/env bash
# Build a Debian package for Tooran from the Flutter Linux release bundle.
#
# Usage: ./packaging/deb/build-deb.sh [--no-flutter-build]
#   --no-flutter-build   Skip `flutter build linux --release` (use existing
#                        build/linux/x64/release/bundle output as-is).
#
# Output: dist/tooran_<version>_amd64.deb

set -euo pipefail

# Resolve project root (script lives in packaging/deb/).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# ── Metadata ─────────────────────────────────────────────────────────
PKG=tooran
# Reverse-DNS app-id. Used as the .desktop filename, the icon filename, and
# StartupWMClass — all three must match the GTK APPLICATION_ID set in
# linux/CMakeLists.txt or the desktop environment can't link the running
# window to its launcher (no icon, raw app-id in tooltip).
APP_ID=io.github.jirugutema.tooran
ARCH=amd64
# Strip the trailing +build from "1.0.0+1" — debian versions can't contain '+'
# the way pubspec uses it without quoting.
VERSION=$(awk '/^version:/ {print $2}' pubspec.yaml | cut -d'+' -f1)
MAINTAINER="${TOORAN_DEB_MAINTAINER:-Jiru Gutema <jirudagutema@gmail.com>}"
DESCRIPTION_SHORT="A simple, quiet task organizer"
DESCRIPTION_LONG=" Tooran lets you keep small lists of things you want to keep close.
 Categories hold tasks. Tasks hold what they hold. Nothing more.
 .
 Local-first: your lists never leave your device unless you say so."

# Runtime dependencies for a Flutter Linux app + plugins in this project.
# (window_manager → libgtk-3, shared_preferences → libglib, url_launcher → xdg-open at runtime.)
DEPENDS="libgtk-3-0, libglib2.0-0, libstdc++6, libc6"

# ── Build the bundle (skip with --no-flutter-build) ──────────────────
if [[ "${1:-}" != "--no-flutter-build" ]]; then
  echo ">>> flutter build linux --release"
  flutter build linux --release
fi

BUNDLE_DIR="build/linux/x64/release/bundle"
if [[ ! -x "$BUNDLE_DIR/$PKG" ]]; then
  echo "Error: missing release bundle at $BUNDLE_DIR/$PKG" >&2
  exit 1
fi

# ── Stage the deb tree ───────────────────────────────────────────────
STAGE="build/deb/${PKG}_${VERSION}_${ARCH}"
echo ">>> Staging $STAGE"
rm -rf "$STAGE"
install -d \
  "$STAGE/DEBIAN" \
  "$STAGE/usr/lib/$PKG" \
  "$STAGE/usr/bin" \
  "$STAGE/usr/share/applications" \
  "$STAGE/usr/share/icons/hicolor/256x256/apps" \
  "$STAGE/usr/share/doc/$PKG"

# Copy the Flutter bundle — binary, lib/, data/ — into /usr/lib/tooran/.
cp -a "$BUNDLE_DIR/." "$STAGE/usr/lib/$PKG/"

# /usr/bin/tooran → /usr/lib/tooran/tooran (symlink; Flutter resolves its
# bundle dir from the resolved binary path via /proc/self/exe, so symlinks
# work transparently).
ln -sf "../lib/$PKG/$PKG" "$STAGE/usr/bin/$PKG"

# Desktop entry + icon. Both filenames must match $APP_ID so GNOME/KDE can
# link the running window (whose GApplication ID is APP_ID) to the launcher.
install -m 644 "$SCRIPT_DIR/$APP_ID.desktop" \
  "$STAGE/usr/share/applications/$APP_ID.desktop"

ICON_SRC=""
for cand in assets/icon.png assets/logo.png; do
  if [[ -f "$cand" ]]; then ICON_SRC="$cand"; break; fi
done
if [[ -n "$ICON_SRC" ]]; then
  install -m 644 "$ICON_SRC" \
    "$STAGE/usr/share/icons/hicolor/256x256/apps/$APP_ID.png"
else
  echo "Warning: no icon found in assets/; skipping icon install" >&2
fi

# Copyright stub (so lintian doesn't complain too loudly).
cat > "$STAGE/usr/share/doc/$PKG/copyright" <<'EOF'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: Tooran
Source: https://github.com/JiruGutema/Tooran

Files: *
Copyright: 2024 Jiru Gutema
License: MIT
 See the LICENSE file in the source tree for the full text.
EOF

# ── DEBIAN/control ──────────────────────────────────────────────────
INSTALLED_KB=$(du -sk "$STAGE/usr" | cut -f1)
cat > "$STAGE/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Depends: $DEPENDS
Installed-Size: $INSTALLED_KB
Maintainer: $MAINTAINER
Homepage: https://tooran.vercel.app
Description: $DESCRIPTION_SHORT
$DESCRIPTION_LONG
EOF

# Refresh the icon cache after install so the .desktop entry shows its icon.
cat > "$STAGE/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -f /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
EOF
chmod 0755 "$STAGE/DEBIAN/postinst"

cat > "$STAGE/DEBIAN/postrm" <<'EOF'
#!/bin/sh
set -e
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q -f /usr/share/icons/hicolor || true
  fi
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications || true
  fi
fi
exit 0
EOF
chmod 0755 "$STAGE/DEBIAN/postrm"

# ── Build the .deb ──────────────────────────────────────────────────
mkdir -p dist
OUT="dist/${PKG}_${VERSION}_${ARCH}.deb"

BUILDER=fakeroot
if ! command -v fakeroot >/dev/null 2>&1; then
  echo "Warning: fakeroot not installed; building with --root-owner-group" >&2
  BUILDER=""
fi

echo ">>> dpkg-deb --build $STAGE $OUT"
if [[ -n "$BUILDER" ]]; then
  $BUILDER dpkg-deb --build "$STAGE" "$OUT"
else
  dpkg-deb --root-owner-group --build "$STAGE" "$OUT"
fi

echo ""
echo "✓ Built $OUT"
ls -lh "$OUT"
echo ""
echo "Inspect:"
echo "  dpkg-deb -I $OUT      # control / metadata"
echo "  dpkg-deb -c $OUT      # file listing"
echo ""
echo "Install:"
echo "  sudo apt install ./$OUT"
echo "  # or: sudo dpkg -i $OUT && sudo apt -f install"
