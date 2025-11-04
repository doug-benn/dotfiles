#!/usr/bin/env bash

# Usage: ./install-go.sh 1.25.3

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <go-version> (e.g., $0 1.25.3)"
  exit 1
fi

VERSION="$1"
ARCH="amd64"
CACHE_DIR="$HOME/.cache/go-installer"
TARBALL="go${VERSION}.linux-${ARCH}.tar.gz"
DOWNLOAD_URL="https://go.dev/dl/${TARBALL}"

mkdir -p "$CACHE_DIR"

if [ -f "$CACHE_DIR/$TARBALL" ]; then
  echo "Using cached Go tarball: $CACHE_DIR/$TARBALL"

else
  echo "Downloading Go $VERSION..."
  wget -q "$DOWNLOAD_URL" -O "$CACHE_DIR/$TARBALL"
fi

if [ -d "/usr/local/go" ]; then
  echo "Removing old Go installation..."
  sudo rm -rf /usr/local/go
fi

echo "Installing Go $VERSION..."
sudo tar -C /usr/local -xzf "$CACHE_DIR/$TARBALL"

if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
  echo "Adding Go to PATH..."
  echo 'export PATH=$PATH:/usr/local/go/bin' >>~/.bashrc
fi

source ~/.bashrc

echo "Installed version:"
go version
