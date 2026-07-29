#!/bin/bash

# ======================================================
#  RIGOROUS ERROR HANDLING & ENVIRONMENT SETUP
# ======================================================
set -euo pipefail

# Definiranje direktorija skripte
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detekcija korisničkih foldera (radi bez obzira na jezik sustava)
PICTURES_DIR=$(xdg-user-dir PICTURES)
DOCUMENTS_DIR=$(xdg-user-dir DOCUMENTS)
echo "INFO: Pictures → $PICTURES_DIR"
echo "INFO: Documents → $DOCUMENTS_DIR"

echo "====================================================="
echo "     POSTINSTALL STARTED (Fedora COSMIC)"
echo "====================================================="


# -------------------------------------------------------
# 1) Ensure base dependencies
# -------------------------------------------------------
echo "[1] Installing base prerequisites..."
sudo dnf install -y ca-certificates curl wget gnupg2 git


# -------------------------------------------------------
# 2) CLEAN DEFAULT JUNK (free space before heavy installs)
# -------------------------------------------------------
echo "[2] Removing unwanted preinstalled applications..."

sudo dnf remove -y \
  libreoffice-base libreoffice-calc libreoffice-core libreoffice-draw \
  libreoffice-impress libreoffice-math libreoffice-writer libreoffice-common \
  gnome-mahjongg gnome-mines gnome-sudoku || true

sudo dnf autoremove -y

echo "[2] Cleanup completed."

# -------------------------------------------------------
# 3) FULL SYSTEM UPDATE BEFORE INSTALLATION
# -------------------------------------------------------
echo "[3] Updating system..."
sudo dnf upgrade -y

# -------------------------------------------------------
# 4) ADD CUSTOM REPOSITORIES & THIRD-PARTY APPS
# -------------------------------------------------------
echo "[4] Adding custom repositories and third-party apps..."

## RPM Fusion (Free + Nonfree) - potreban za Steam, Wine, codece itd.
if ! rpm -q rpmfusion-free-release &>/dev/null; then
    echo " → RPM Fusion Free"
    sudo dnf install -y \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
fi

if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
    echo " → RPM Fusion Nonfree"
    sudo dnf install -y \
      https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi

## Funkcija za pouzdanu RPM/DEB instalaciju
install_rpm() {
    local URL=$1
    local FILENAME=$2
    local TMP_RPM="/tmp/$FILENAME.rpm"

    echo " → $FILENAME (.rpm install)"
    (
        wget -O "$TMP_RPM" "$URL" || { echo "ERROR: Failed to download $FILENAME RPM." >&2; exit 1; }
        sudo dnf install -y "$TMP_RPM"
        rm -f "$TMP_RPM"
    )
}

# MegaSync za Fedoru
install_rpm "https://mega.nz/linux/repo/Fedora_$(rpm -E %fedora)/x86_64/megasync-Fedora_$(rpm -E %fedora).x86_64.rpm" "megasync"

# Master PDF Editor
install_rpm "https://code-industry.net/public/master-pdf-editor-5.9.60-qt5.x86_64.rpm" "masterpdf"

# --- VS Code ---
echo "[+] Installing VS Code..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

# --- Pokretanje Anaconda skripte ---
bash "$REPO_DIR/languages/install_conda.sh"

echo "[4] Repositories and third-party apps added."

# -------------------------------------------------------
# 5) REFRESH DNF AFTER REPOS
# -------------------------------------------------------
echo "[5] Refreshing DNF after adding repositories..."
sudo dnf makecache

# -------------------------------------------------------
# 6) RUN DNF INSTALLER SCRIPT
# -------------------------------------------------------
echo "[6] Installing DNF packages..."
bash "$REPO_DIR/dnf/install.sh"

# -------------------------------------------------------
# 7) RUN FLATPAK INSTALLER SCRIPT
# -------------------------------------------------------
echo "[7] Installing Flatpak packages..."

# Fedora dolazi s Flatpakom, ali provjeri Flathub
if ! flatpak remotes | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

flatpak uninstall --unused -y || true
bash "$REPO_DIR/flatpak/install.sh"


# ======================================================
# KONFIGURACIJE
# ======================================================

# -------------------------------------------------------
# 8) RESTORE DOTFILES
# -------------------------------------------------------
if [ -d "$REPO_DIR/dotfiles" ]; then
    echo "[8a] Restoring dotfiles..."
    cp -rT "$REPO_DIR/dotfiles" "$HOME/"
fi

if [ -d "$REPO_DIR/wal" ]; then
    echo "[8b] Restoring pywal..."
    cp -rT "$REPO_DIR/wal" "$HOME/.cache/wal/"
fi

# -------------------------------------------------------
# 9) RESTORE DESKTOP CONFIG (COSMIC / Kitty / ikone)
# -------------------------------------------------------
if [ -d "$REPO_DIR/cosmic" ]; then
    echo "[9] Restoring COSMIC settings..."
    mkdir -p "$HOME/.config/cosmic"
    cp -rT "$REPO_DIR/cosmic" "$HOME/.config/cosmic/"
fi

echo "[9b] Installing Kitty configuration..."
mkdir -p "$HOME/.config/kitty"
cp -rT "$REPO_DIR/kitty" "$HOME/.config/kitty/"

if [ -d "$REPO_DIR/icons" ]; then
    echo "[9c] Restoring icons..."
    mkdir -p "$HOME/.local/share/icons"
    cp -rT "$REPO_DIR/icons" "$HOME/.local/share/icons"
fi

# Postavi ikone direktno u COSMIC config
echo "[9d] Setting COSMIC icon theme..."
mkdir -p "$HOME/.config/cosmic/com.system76.CosmicTk/v1"
echo '"Colloid-teal-dark"' > "$HOME/.config/cosmic/com.system76.CosmicTk/v1/icon_theme"

# -------------------------------------------------------
# 10) WALLPAPER
# -------------------------------------------------------
echo "[10] Installing wallpapers..."

WALLPAPER_SOURCE_DIR="$REPO_DIR/wallpapers"
TARGET_DIR="$PICTURES_DIR/Wallpaper"
TARGET_FILE="$TARGET_DIR/jutro 4K.jpg"

if [ -d "$WALLPAPER_SOURCE_DIR" ]; then
    echo " → Copying ALL wallpapers from repo to $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
    cp -rT "$WALLPAPER_SOURCE_DIR" "$TARGET_DIR"

    if [ -f "$TARGET_FILE" ]; then
        echo " → Setting COSMIC wallpaper..."
        mkdir -p "$HOME/.config/cosmic/com.system76.CosmicBackground/v1"
        cat > "$HOME/.config/cosmic/com.system76.CosmicBackground/v1/all" << EOF
(
    output: "all",
    source: Path("$TARGET_FILE"),
    filter_by_theme: true,
    rotation_frequency: 300,
    filter_method: Lanczos,
    scaling_mode: Zoom,
    sampling_method: Alphanumeric,
)
EOF
        echo "INFO: COSMIC wallpaper config written."
    else
        echo "ERROR: Default wallpaper file ($TARGET_FILE) not found after copy."
    fi
else
    echo "WARNING: Wallpapers directory not found in repository. Skipping wallpaper setup."
fi

# -------------------------------------------------------
# 11) LANGUAGE/ENVIRONMENT INSTALLS (Go, rbenv, Conda)
# -------------------------------------------------------
echo "[11] Installing language environments (Go, Ruby)..."

echo " → Running install_go.sh"
bash "$REPO_DIR/languages/install_go.sh"

echo " → Running install_rbenv.sh"
bash "$REPO_DIR/languages/install_rbenv.sh"

# -------------------------------------------------------
# 12) CONFIGURE ZSH (conda + rbenv PATH)
# -------------------------------------------------------
echo "[12] Configuring zsh for conda and rbenv..."

ZSHRC="$HOME/.zshrc"

# rbenv
if ! grep -q 'rbenv' "$ZSHRC" 2>/dev/null; then
cat >> "$ZSHRC" << 'EOF'

# rbenv
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"
EOF
fi

# conda
DOCUMENTS_DIR=$(xdg-user-dir DOCUMENTS)
CONDA_PATH="$DOCUMENTS_DIR/anaconda3"
if [ -f "$CONDA_PATH/bin/conda" ] && ! grep -q 'anaconda3' "$ZSHRC" 2>/dev/null; then
    "$CONDA_PATH/bin/conda" init zsh
fi

# -------------------------------------------------------
# 13) FINAL CLEANUP
# -------------------------------------------------------
echo "[13] Final cleanup..."
sudo dnf autoremove -y
flatpak uninstall --unused -y || true

echo "====================================================="
echo "     POSTINSTALL COMPLETE"
echo "====================================================="
echo "SUSTAV ĆE IZVESTI REBOOT SADA."
sleep 3
reboot