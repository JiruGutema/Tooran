# Packaging Tooran

How to build a Debian package (`.deb`) of the Tooran Linux desktop app.

The automated path is `./packaging/deb/build-deb.sh` from the project root.
Everything below documents what that script does so you can reproduce it by
hand, debug a failure, or port the recipe to another distro.

## 1. Prerequisites

Install once on the build machine:

```bash
sudo apt install dpkg-dev fakeroot
```

You also need:

- **Flutter SDK** with Linux desktop support enabled
  (`flutter config --enable-linux-desktop`).
- The Linux toolchain Flutter requires:
  ```bash
  sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
  ```
- (Optional) `lintian` if you want to policy-check the resulting `.deb`.

Confirm the build target works on its own first:

```bash
flutter doctor
flutter build linux --release
./build/linux/x64/release/bundle/tooran    # smoke test
```

## 2. One-shot build

From the project root:

```bash
./packaging/deb/build-deb.sh
```

This runs `flutter build linux --release`, stages the Debian tree, and writes
`dist/tooran_<version>_amd64.deb`.

If the bundle is already fresh and you just want to re-package:

```bash
./packaging/deb/build-deb.sh --no-flutter-build
```

Override the maintainer line (the default is a placeholder):

```bash
TOORAN_DEB_MAINTAINER="Jiru Gutema <you@example.com>" \
  ./packaging/deb/build-deb.sh
```

The version is read from `pubspec.yaml` (`version:` line, with the `+build`
suffix stripped — Debian versions don't accept `+N` the way pubspec uses it).

## 3. What the script does, step by step

If you'd rather drive it by hand, these are the same steps the script runs.

### 3.1 Build the Flutter Linux release bundle

```bash
flutter build linux --release
```

Output lives at `build/linux/x64/release/bundle/`:

```
bundle/
├── tooran          # the executable
├── data/           # flutter_assets (fonts, icons, NOTICES, AssetManifest…)
└── lib/            # the Flutter engine .so + plugin libs
```

The whole bundle is ~52 MB; the engine accounts for most of that.

### 3.2 Stage a Debian package tree

Final on-disk layout:

```
build/deb/tooran_<version>_amd64/
├── DEBIAN/
│   ├── control     # package metadata
│   ├── postinst    # refreshes icon + desktop caches after install
│   └── postrm      # refreshes them again on remove/purge
└── usr/
    ├── bin/
    │   └── tooran                                 # → ../lib/tooran/tooran
    ├── lib/
    │   └── tooran/                                # full Flutter bundle
    ├── share/
    │   ├── applications/tooran.desktop
    │   ├── icons/hicolor/256x256/apps/tooran.png
    │   └── doc/tooran/copyright
```

Why a symlink in `/usr/bin` instead of a wrapper script: Flutter resolves its
bundle directory by reading `/proc/self/exe`, which returns the resolved
(real) path, so a symlink works transparently and avoids a shell wrapper.

```bash
PKG=tooran
ARCH=amd64
VERSION=$(awk '/^version:/ {print $2}' pubspec.yaml | cut -d'+' -f1)
STAGE="build/deb/${PKG}_${VERSION}_${ARCH}"

rm -rf "$STAGE"
install -d \
  "$STAGE/DEBIAN" \
  "$STAGE/usr/lib/$PKG" \
  "$STAGE/usr/bin" \
  "$STAGE/usr/share/applications" \
  "$STAGE/usr/share/icons/hicolor/256x256/apps" \
  "$STAGE/usr/share/doc/$PKG"

cp -a build/linux/x64/release/bundle/. "$STAGE/usr/lib/$PKG/"
ln -sf "../lib/$PKG/$PKG" "$STAGE/usr/bin/$PKG"

install -m 644 packaging/deb/tooran.desktop \
  "$STAGE/usr/share/applications/$PKG.desktop"
install -m 644 assets/icon.png \
  "$STAGE/usr/share/icons/hicolor/256x256/apps/$PKG.png"
```

### 3.3 Write `DEBIAN/control`

```bash
INSTALLED_KB=$(du -sk "$STAGE/usr" | cut -f1)

cat > "$STAGE/DEBIAN/control" <<EOF
Package: tooran
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libglib2.0-0, libstdc++6, libc6
Installed-Size: $INSTALLED_KB
Maintainer: Jiru Gutema <jirugutema@example.com>
Homepage: https://tooran.vercel.app
Description: A simple, quiet task organizer
 Tooran lets you keep small lists of things you want to keep close.
 Categories hold tasks. Tasks hold what they hold. Nothing more.
 .
 Local-first: your lists never leave your device unless you say so.
EOF
```

`Depends:` covers what a Flutter Linux app actually needs at runtime:
- `libgtk-3-0` — Flutter Linux uses GTK for the window/event loop.
- `libglib2.0-0` — pulled in by GTK and `shared_preferences`.
- `libstdc++6`, `libc6` — C/C++ runtimes.

If you add native plugins later (e.g. `flutter_secret_storage` →
`libsecret-1-0`), append them here.

### 3.4 Maintainer scripts

`DEBIAN/postinst` refreshes the icon cache and desktop database so the new
launcher entry is picked up immediately:

```sh
#!/bin/sh
set -e
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -f /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
```

`DEBIAN/postrm` runs the same refresh on `remove` / `purge`. Both must be
`chmod 0755`.

### 3.5 Build the `.deb`

```bash
mkdir -p dist
fakeroot dpkg-deb --build "$STAGE" "dist/tooran_${VERSION}_amd64.deb"
```

Why `fakeroot`: `dpkg-deb` records ownership of every file. `fakeroot`
makes the contents look root-owned without needing actual root privileges,
which keeps the build script unprivileged. If `fakeroot` isn't available,
fall back to `dpkg-deb --root-owner-group --build …`.

## 4. Verify the package

```bash
dpkg-deb -I dist/tooran_1.0.0_amd64.deb     # control / metadata
dpkg-deb -c dist/tooran_1.0.0_amd64.deb     # full file listing
lintian   dist/tooran_1.0.0_amd64.deb       # optional policy lint
```

Spot-check that the symlink and launcher entry are both present:

```bash
dpkg-deb -c dist/tooran_1.0.0_amd64.deb | grep -E '(usr/bin|tooran\.desktop|hicolor)'
```

You should see:

```
lrwxrwxrwx  ./usr/bin/tooran -> ../lib/tooran/tooran
-rw-r--r--  ./usr/share/applications/tooran.desktop
-rw-r--r--  ./usr/share/icons/hicolor/256x256/apps/tooran.png
```

## 5. Install & test

```bash
sudo apt install ./dist/tooran_1.0.0_amd64.deb
# or, the lower-level path:
sudo dpkg -i dist/tooran_1.0.0_amd64.deb && sudo apt -f install
```

Then either:

- Launch from the application menu (look for **Tooran**), or
- Run `tooran` from a terminal.

Uninstall with:

```bash
sudo apt remove tooran        # keeps user data in ~/.local/share
sudo apt purge tooran         # removes everything
```

## 6. Customizing for distribution

Before publishing the `.deb` publicly, consider:

- **Maintainer line** — set `TOORAN_DEB_MAINTAINER` or edit the default in
  `packaging/deb/build-deb.sh`. Use a real email; some package tooling
  rejects `example.com`.
- **Application ID** — `linux/CMakeLists.txt` still ships the Flutter
  scaffold default `com.example.tooran`. Change it to something unique
  (e.g. `dev.jirugutema.tooran`) so DBus / GTK identify the app correctly.
- **Version bumps** — bump `version:` in `pubspec.yaml`. The script picks it
  up automatically.
- **More icon sizes** — only `256x256` ships today. For sharper icons in
  panels/launchers, generate `16, 32, 48, 64, 128` PNGs and install them
  into the matching `hicolor/<size>/apps/` directories.
- **Lintian cleanup** — `lintian` will flag the placeholder maintainer,
  the missing `changelog.Debian.gz`, and (depending on your toolchain) the
  unstripped binary. Address as needed before uploading anywhere.

## 7. Files in this directory

```
packaging/
├── README.md           # this file
└── deb/
    ├── build-deb.sh    # one-shot build script (steps 3.1 – 3.5)
    └── tooran.desktop  # XDG launcher entry installed under /usr/share/applications/
```

Build artifacts land in `dist/` (the final `.deb`) and `build/deb/` (the
staging tree). Both are intermediate output — safe to delete and rebuild.
