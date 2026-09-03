#!/usr/bin/env bash
# Package an existing `flutter build linux --release` bundle four ways:
# .deb, .rpm, .tar.gz and .AppImage.
#
#   tools/package_linux.sh <version> <build-number> [bundle-dir] [out-dir]
#   tools/package_linux.sh 0.5.0 42
#
# The Debian package is named `sielto` (the binary); release files are named
# `sielto-app-*` to match the other platforms' artifacts.
#
# Needs: dpkg-deb, tar. rpmbuild for the .rpm and appimagetool for the
# AppImage — each format is skipped with a warning if its tool is missing.
set -euo pipefail

VERSION=${1:?usage: package_linux.sh <version> <build-number> [bundle-dir] [out-dir]}
BUILD=${2:?missing build number}
BUNDLE=${3:-build/linux/x64/release/bundle}
OUT=${4:-build/packages}

PKG=sielto
BIN=sielto
APP_ID=dev.edvig.sielto
ICON=linux/runner/resources/sielto.png

[ -x "$BUNDLE/$BIN" ] || { echo "no release bundle at $BUNDLE" >&2; exit 1; }
[ -f "$ICON" ] || { echo "no icon at $ICON" >&2; exit 1; }

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$OUT"
OUT=$(cd "$OUT" && pwd)

# ---------------------------------------------------------------- staging tree
# One FHS tree, shared by the deb and the rpm. The bundle keeps its own layout
# under /usr/lib/sielto because the binary resolves data/ and lib/ relative to
# itself; /usr/bin/sielto is a symlink into it.
ROOT=$WORK/root
install -d "$ROOT/usr/lib/$PKG" "$ROOT/usr/bin" \
  "$ROOT/usr/share/applications" \
  "$ROOT/usr/share/icons/hicolor/512x512/apps" \
  "$ROOT/usr/share/doc/$PKG"

cp -r "$BUNDLE/." "$ROOT/usr/lib/$PKG/"
ln -s "../lib/$PKG/$BIN" "$ROOT/usr/bin/$BIN"
install -m 644 "$ICON" "$ROOT/usr/share/icons/hicolor/512x512/apps/$BIN.png"
install -m 644 LICENSE "$ROOT/usr/share/doc/$PKG/copyright"

# Written outside the staging tree and installed from there, so the formats
# built after the rpm do not read anything rpm might have cleaned up.
DESKTOP_FILE=$WORK/$APP_ID.desktop
cat > "$DESKTOP_FILE" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Sielto
GenericName=Budget planner
Comment=Offline-first planner for mandatory payments and shared budgets
Exec=$BIN
Icon=$BIN
Terminal=false
Categories=Office;Finance;
StartupWMClass=$BIN
DESKTOP
install -m 644 "$DESKTOP_FILE" \
  "$ROOT/usr/share/applications/$APP_ID.desktop"

SIZE_KB=$(du -sk "$ROOT/usr" | cut -f1)

# ------------------------------------------------------------------------ .deb
# libgtk-3-0 was renamed libgtk-3-0t64 in the Ubuntu 24.04 time64 transition;
# the alternative keeps one package installable on both.
DEB=$WORK/deb
cp -r "$ROOT" "$DEB"
install -d "$DEB/DEBIAN"
cat > "$DEB/DEBIAN/control" <<CONTROL
Package: $PKG
Version: $VERSION+$BUILD
Architecture: amd64
Maintainer: Edvig Smirnov <edvig.smirnov@16-tons.com>
Installed-Size: $SIZE_KB
Depends: libgtk-3-0t64 | libgtk-3-0, libsecret-1-0, libstdc++6, libc6
Section: misc
Priority: optional
Homepage: https://github.com/edvigsmirnov/sielto-app
Description: Offline-first planner for mandatory payments and shared budgets
 Sielto answers one question: how much can I actually spend? It subtracts
 every upcoming obligation from the money that has arrived, including the
 ones that only land at the end of the month.
 .
 The on-device database is the source of truth and is encrypted at rest.
 No account, no telemetry, no bank connection.
CONTROL

DEB_FILE="$OUT/sielto-app_$VERSION+${BUILD}_amd64.deb"
dpkg-deb --root-owner-group --build "$DEB" "$DEB_FILE" >/dev/null
echo "deb      $(basename "$DEB_FILE")"

# ------------------------------------------------------------------------ .rpm
# Requires are sonames, not distro package names, so one rpm resolves on
# Fedora, openSUSE and Mageia alike. AutoReqProv is off because the bundled
# libraries under /usr/lib/sielto are private and must not be advertised.
if command -v rpmbuild >/dev/null 2>&1; then
  SPEC=$WORK/$PKG.spec
  cat > "$SPEC" <<SPEC
Name:           $PKG
Version:        $VERSION
Release:        $BUILD
Summary:        Offline-first planner for mandatory payments and shared budgets
License:        LicenseRef-Sielto-NonCommercial
URL:            https://github.com/edvigsmirnov/sielto-app
BuildArch:      x86_64
AutoReqProv:    no
Requires:       libgtk-3.so.0()(64bit)
Requires:       libsecret-1.so.0()(64bit)
Requires:       libstdc++.so.6()(64bit)

%description
Sielto answers one question: how much can I actually spend? It subtracts every
upcoming obligation from the money that has arrived, including the ones that
only land at the end of the month.

The on-device database is the source of truth and is encrypted at rest.
No account, no telemetry, no bank connection.

%files
/usr/lib/$PKG
/usr/bin/$BIN
/usr/share/applications/$APP_ID.desktop
/usr/share/icons/hicolor/512x512/apps/$BIN.png
/usr/share/doc/$PKG/copyright
SPEC

  # rpm 4.x deletes its buildroot once the package is written, so it gets a
  # throwaway copy: pointing it at $ROOT took the staging tree out from under
  # the formats built after it. rpm 6 leaves the buildroot alone, which is why
  # this only ever failed on CI.
  RPMROOT=$WORK/rpm-buildroot
  cp -r "$ROOT" "$RPMROOT"

  # _dbpath: never read the system rpm database, which is unreadable to a
  # normal user and irrelevant here. _buildhost: rpm stamps the hostname
  # otherwise, and these artifacts are published.
  rpmbuild -bb "$SPEC" \
    --define "_topdir $WORK/rpmbuild" \
    --buildroot "$RPMROOT" \
    --define "_rpmdir $WORK/rpmout" \
    --define "_dbpath $WORK/rpmdb" \
    --define "_buildhost sielto-build" \
    --quiet
  RPM_BUILT=$(find "$WORK/rpmout" -name '*.rpm' -print -quit)
  RPM_FILE="$OUT/sielto-app-$VERSION-$BUILD.x86_64.rpm"
  mv "$RPM_BUILT" "$RPM_FILE"
  echo "rpm      $(basename "$RPM_FILE")"
else
  echo "rpm      skipped: rpmbuild not found" >&2
fi

# --------------------------------------------------------------------- tar.gz
# Relocatable: runs from anywhere as ./sielto, for distros with no package and
# for downstream packagers.
TAR=$WORK/tar/sielto-app-$VERSION+$BUILD-linux-x64
install -d "$TAR"
cp -r "$BUNDLE/." "$TAR/"
install -m 644 LICENSE "$TAR/LICENSE"
install -m 644 "$ICON" "$TAR/$BIN.png"
install -m 644 "$DESKTOP_FILE" "$TAR/"
cat > "$TAR/INSTALL.txt" <<INSTALL
Sielto $VERSION+$BUILD (linux-x64)

Run ./sielto from this directory. Nothing needs installing.

Requires GTK 3 and libsecret at runtime; both ship with any current desktop
Linux. Debian/Ubuntu: libgtk-3-0 (or libgtk-3-0t64) and libsecret-1-0.
Fedora: gtk3 and libsecret. libsecret holds the database key in the desktop
keyring, so the app cannot start without it.

To add a menu entry, copy $APP_ID.desktop into
~/.local/share/applications/ and set Exec= to the absolute path of ./sielto,
then copy $BIN.png into ~/.local/share/icons/.
INSTALL

TAR_FILE="$OUT/sielto-app-$VERSION+$BUILD-linux-x64.tar.gz"
tar -czf "$TAR_FILE" -C "$WORK/tar" "$(basename "$TAR")"
echo "tar.gz   $(basename "$TAR_FILE")"

# ------------------------------------------------------------------- AppImage
if command -v appimagetool >/dev/null 2>&1; then
  APPDIR=$WORK/AppDir
  install -d "$APPDIR/usr/bin"
  cp -r "$BUNDLE/." "$APPDIR/usr/bin/"
  install -m 644 "$DESKTOP_FILE" "$APPDIR/$BIN.desktop"
  # appimagetool wants the icon beside the .desktop file.
  install -m 644 "$ICON" "$APPDIR/$BIN.png"
  cat > "$APPDIR/AppRun" <<'APPRUN'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/sielto" "$@"
APPRUN
  chmod +x "$APPDIR/AppRun"

  APPIMAGE_FILE="$OUT/sielto-app-$VERSION+$BUILD-x86_64.AppImage"
  # --appimage-extract-and-run: CI runners have no FUSE to mount the tool.
  # stdout is noise; stderr is kept, or a failure here has no explanation.
  ARCH=x86_64 appimagetool --appimage-extract-and-run "$APPDIR" "$APPIMAGE_FILE" \
    >/dev/null
  echo "AppImage $(basename "$APPIMAGE_FILE")"
else
  echo "AppImage skipped: appimagetool not found" >&2
fi

# Every format whose tool was present must have produced a file. Without this a
# half-finished run still exits 0 and CI uploads whatever happens to be there.
missing=0
for f in "$DEB_FILE" "$TAR_FILE" ${RPM_FILE:+"$RPM_FILE"} \
  ${APPIMAGE_FILE:+"$APPIMAGE_FILE"}; do
  [ -s "$f" ] || { echo "missing or empty: $f" >&2; missing=1; }
done
[ "$missing" -eq 0 ] || exit 1

echo
ls -lh "$OUT" | tail -n +2 | awk '{print "  " $5, $9}'
