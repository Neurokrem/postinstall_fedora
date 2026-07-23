#!/bin/bash
set -euo pipefail

echo "====================================================="
echo "   POSTINSTALL BOOTSTRAP START (Fedora COSMIC)"
echo "====================================================="

# 1) Provjera da je git instaliran
if ! command -v git >/dev/null 2>&1; then
    echo "[+] Installing git..."
    sudo dnf install -y git
fi

# 2) Kreiranje privremene mape
TMPDIR=$(mktemp -d)

# Varijabla za Vaš repozitorij
REPO_URL="https://github.com/Neurokrem/postinstall_fedora.git"

echo "[+] Cloning repository $REPO_URL into: $TMPDIR"
git clone "$REPO_URL" "$TMPDIR"

# 3) Provjera da je kloniranje uspjelo
if [ ! -f "$TMPDIR/postinstall.sh" ]; then
    echo "[ERROR] postinstall.sh not found in cloned repo! Aborting."
    exit 1
fi

cd "$TMPDIR"

echo "[+] Setting execute permissions for all .sh scripts..."
find . -name "*.sh" -exec chmod +x {} \;

echo "-----------------------------------------------------"
echo "  Running postinstall.sh..."
echo "-----------------------------------------------------"

./postinstall.sh

echo "-----------------------------------------------------"
echo "  Postinstall completed."
echo "-----------------------------------------------------"

echo "Cleaning up temporary directory..."
rm -rf "$TMPDIR"

echo "====================================================="
echo "   BOOTSTRAP DONE — restart recommended"
echo "====================================================="
