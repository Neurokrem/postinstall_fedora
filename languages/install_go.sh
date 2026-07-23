#!/bin/bash
echo "[Go] Installing Go..."

GO_VERSION="1.22.5"
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_TAR}"

cd /tmp || exit 1

wget -q "$GO_URL"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$GO_TAR"

# PATH (za zsh i bash)
if ! grep -q '/usr/local/go/bin' ~/.profile; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi

echo " → Go installed: /usr/local/go"
