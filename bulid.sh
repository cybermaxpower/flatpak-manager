#!/usr/bin/env bash

# Title: Debian Package Builder for Flatpak Manager
# Version: 1.0.0
# Description: Generates a fully Lintian-compliant .deb installer package 
# with copyright, changelog, man pages, maintainer scripts, and policy checks.


# SECTION: Directory Creation
# Creates the temporary Debian build environment tree including doc/man paths
BUILD_DIR="flatpak-manager_1.0.0-1_all"
DOC_DIR="$BUILD_DIR/usr/share/doc/flatpak-manager"
MAN_DIR="$BUILD_DIR/usr/share/man/man1"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/bin"
mkdir -p "$BUILD_DIR/usr/share/applications"
mkdir -p "$DOC_DIR"
mkdir -p "$MAN_DIR"


# SECTION: Control File Generation
# Writes Debian package information and system dependencies
cat << EOF > "$BUILD_DIR/DEBIAN/control"
Package: flatpak-manager
Version: 1.0.0-1
Section: utils
Priority: optional
Architecture: all
Depends: flatpak, zenity, xdg-utils, desktop-file-utils
Maintainer: cybermaxpower <cybermaxpower@github.com>
Description: Graphical Flatpak package inspector and manager
 A Zenity-based graphical utility to inspect, install, update,
 and remove Flatpak packages and reference files.
EOF


# SECTION: Copyright File Generation (DEP-5 Format)
# Satisfies Lintian: no-copyright-file
cat << EOF > "$DOC_DIR/copyright"
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: flatpak-manager
Upstream-Contact: cybermaxpower <cybermaxpower@github.com>
Source: https://github.com/cybermaxpower/flatpak-manager

Files: *
Copyright: 2026 cybermaxpower <cybermaxpower@github.com>
License: GPL-3.0+
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.
EOF

chmod 644 "$DOC_DIR/copyright"


# SECTION: Debian Changelog Generation
# Satisfies Lintian: no-changelog-created-by-dh
BUILD_DATE=$(date -R)
cat << EOF > "$DOC_DIR/changelog.Debian"
flatpak-manager (1.0.0-1) unstable; urgency=low

  * Initial release of Flatpak Manager v1.0.0.
  * Added graphical inspection, installation, and MIME desktop integration.

 -- cybermaxpower <cybermaxpower@github.com>  $BUILD_DATE
EOF

chmod 644 "$DOC_DIR/changelog.Debian"
gzip -n -9 "$DOC_DIR/changelog.Debian"


# SECTION: Man Page Generation
# Satisfies Lintian: binary-without-manpage
cat << 'EOF' > "$MAN_DIR/flatpak-manager.1"
.TH FLATPAK-MANAGER 1 "August 2026" "1.0.0" "User Commands"
.SH NAME
flatpak-manager \- Graphical Flatpak package inspector and manager
.SH SYNOPSIS
.B flatpak-manager
[\fIFILE\fR]
.SH DESCRIPTION
.B flatpak-manager
is a Zenity-based graphical utility to inspect, install, update, and remove Flatpak packages and reference files.
.SH OPTIONS
.TP
.I FILE
Optional path to a .flatpak or .flatpakref file to open and inspect.
.SH AUTHOR
cybermaxpower <cybermaxpower@github.com>
EOF

chmod 644 "$MAN_DIR/flatpak-manager.1"
gzip -n -9 "$MAN_DIR/flatpak-manager.1"


# SECTION: Post-Installation Script Generation
# Creates the DEBIAN/postinst script to refresh desktop and MIME databases on install
cat << 'EOF' > "$BUILD_DIR/DEBIAN/postinst"
#!/bin/sh
set -e

case "$1" in
    configure)
        if command -v update-desktop-database >/dev/null 2>&1; then
            update-desktop-database -q /usr/share/applications || true
        fi

        if command -v update-mime-database >/dev/null 2>&1; then
            update-mime-database /usr/share/mime || true
        fi
        ;;
esac

exit 0
EOF

chmod 755 "$BUILD_DIR/DEBIAN/postinst"


# SECTION: Post-Removal Script Generation
# Creates the DEBIAN/postrm script to clean up desktop and MIME databases on removal
cat << 'EOF' > "$BUILD_DIR/DEBIAN/postrm"
#!/bin/sh
set -e

case "$1" in
    remove|purge)
        if command -v update-desktop-database >/dev/null 2>&1; then
            update-desktop-database -q /usr/share/applications || true
        fi

        if command -v update-mime-database >/dev/null 2>&1; then
            update-mime-database /usr/share/mime || true
        fi
        ;;
esac

exit 0
EOF

chmod 755 "$BUILD_DIR/DEBIAN/postrm"


# SECTION: Desktop Entry Generation
# Creates system-wide menu item and file handler registration with clean Freedesktop categories
cat << EOF > "$BUILD_DIR/usr/share/applications/FlatpakManager.desktop"
[Desktop Entry]
Type=Application
Name=Flatpak Manager
Comment=Inspect and install Flatpak packages
Exec=/usr/bin/flatpak-manager %f
Icon=system-software-install
Terminal=false
Categories=System;PackageManager;
MimeType=application/vnd.flatpak.ref;application/vnd.flatpak;
NoDisplay=false
EOF


# SECTION: Executable Placement
# Copies your flatpak-manager script into the package binary folder
if [[ -f "flatpak-manager" ]]; then
    cp flatpak-manager "$BUILD_DIR/usr/bin/flatpak-manager"
else
    echo "Warning: flatpak-manager not found in current directory."
    echo "Creating a placeholder binary file."
    touch "$BUILD_DIR/usr/bin/flatpak-manager"
fi

chmod 755 "$BUILD_DIR/usr/bin/flatpak-manager"


# SECTION: Package Build Execution
# Compiles the directory structure into a .deb package
PACKAGE_NAME="flatpak-manager_1.0.0-1_all.deb"
dpkg-deb --build "$BUILD_DIR" "$PACKAGE_NAME"

echo "Build complete: $PACKAGE_NAME"


# SECTION: Lintian Quality Control
# Runs Lintian audit if installed on system
if command -v lintian >/dev/null 2>&1; then
    echo "----------------------------------------"
    echo "Running Lintian Policy Checks..."
    echo "----------------------------------------"
    lintian -i -I "$PACKAGE_NAME" || true
else
    echo "Lintian is not installed. Run 'sudo apt install lintian' to enable policy checks."
fi