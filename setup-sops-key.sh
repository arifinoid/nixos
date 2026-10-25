#!/bin/bash
# Setup SOPS age key for NixOS.
#
# This generates a NEW key. If secrets/secret.yaml is already encrypted, use
# ./restore-sops-key.sh instead: a new key cannot decrypt existing secrets.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
KEY_PATH="/var/lib/sops-nix/key.txt"

echo "Setting up SOPS age key..."

if [ -f "$SCRIPT_DIR/secrets/secret.yaml" ] \
    && grep -q 'ENC\[' "$SCRIPT_DIR/secrets/secret.yaml" \
    && [ ! -f "$KEY_PATH" ]; then
    echo ""
    echo "WARNING: secrets/secret.yaml is already encrypted."
    echo "A newly generated key CANNOT decrypt it."
    echo "Restore the existing key instead: ./restore-sops-key.sh <key-file|->"
    echo "Continue only if you are re-keying, then run 'sops updatekeys'"
    echo "from a machine that can still decrypt."
    echo ""
fi

# Create the directory if it doesn't exist
sudo install -d -m 0700 -o root -g root /var/lib/sops-nix

# Generate the age key if it doesn't exist
if [ ! -f "$KEY_PATH" ]; then
    echo "Generating SOPS age key..."
    sudo nix-shell -p age --run "age-keygen -o $KEY_PATH"
    sudo chmod 0400 "$KEY_PATH"
    echo "Age key generated at $KEY_PATH"
    echo ""
    echo "Public key (add it to .sops.yaml before re-encrypting):"
    sudo nix-shell -p age --run "age-keygen -y $KEY_PATH"
else
    echo "Age key already exists at $KEY_PATH"
    echo "To replace it with an existing key, run: ./restore-sops-key.sh --force <key-file>"
fi

echo ""
echo "Setup complete!"
echo ""
echo "Now you can rebuild your configuration:"
echo "sudo nixos-rebuild switch --flake .#wsl-arifinoid"
