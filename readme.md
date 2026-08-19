"# Flatpak Manager

Flatpak Manager is a lightweight, Zenity-based graphical utility designed to inspect, install, update, and manage Flatpak applications on Linux systems. 

It allows you to view package metadata from downloaded .flatpak or .flatpakref files before installing them, and integrates directly with file managers like Nemo for easy double-click package inspection.

## Features

- Package Inspection: View application name, App ID, branch, required runtime, and installation status before committing to an install.
- Graphical Operations: User-friendly Zenity dialogs with progress indicators for installations, updates, and removals.
- Full Package Management: Includes options to check for updates, list installed Flatpak applications, and remove unused runtime dependencies.
- Desktop & MIME Integration: Automatically associates with .flatpak and .flatpakref files in desktop file managers.

## Dependencies

Flatpak Manager requires the following packages to be installed on your system:

- flatpak
- zenity
- xdg-utils
- desktop-file-utils

On Debian/Ubuntu-based distributions, install them with:

sudo apt update
sudo apt install flatpak zenity xdg-utils desktop-file-utils

## Installation

### Option 1: Install via Pre-built .deb Package

Download the latest .deb release from the repository and install it using apt:

sudo apt install ./flatpak-manager_1.0.0-1_all.deb

### Option 2: Standalone Script Execution

You can run the script directly without installing the package:

chmod +x flatpak-manager
./flatpak-manager

To inspect a specific file directly from the command line:

./flatpak-manager /path/to/application.flatpakref

## Building the Debian Package

To compile the .deb installer package yourself, make sure build-deb.sh and flatpak-manager are in the same directory, then run:

chmod +x build-deb.sh
./build-deb.sh

This generates flatpak-manager_1.0.0-1_all.deb complete with system menu shortcuts, man pages, copyright metadata, and post-installation database refresh scripts.

## License

This project is licensed under the GNU General Public License v3.0 or later (GPL-3.0+). See the LICENSE file for details."