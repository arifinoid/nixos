#!/bin/bash
# Setup script for hybrid pass + SOPS secrets management

echo "Setting up hybrid secrets management..."

# 1. Delete test pass entry if it exists
echo "Cleaning up test pass entries..."
pass rm arifinoid/openai.api.key 2>/dev/null || echo "No test entry to remove"

# 2. Encrypt the SOPS secrets file
echo "Encrypting SOPS secrets file..."
sops --encrypt --in-place secrets/secret.yaml

# 3. Initialize SOPS age key if needed
if [ ! -f "/var/lib/sops-nix/key.txt" ]; then
    echo "Generating SOPS age key..."
    sudo nix-shell -p sops --run 'sops --generate-key > /var/lib/sops-nix/key.txt'
fi

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit secrets/secret.yaml with your actual API keys:"
echo "   sops secrets/secret.yaml"
echo ""
echo "2. Add your API key to pass:"
echo "   pass insert arifinoid/openai.api.key"
echo ""
echo "3. Rebuild your configuration:"
echo "   sudo nixos-rebuild switch --flake .#wsl-arifinoid"
