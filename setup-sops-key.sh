#!/bin/bash
# Setup SOPS age key for NixOS

echo "Setting up SOPS age key..."

# Create the directory if it doesn't exist
sudo mkdir -p /var/lib/sops-nix

# Generate the age key if it doesn't exist
if [ ! -f "/var/lib/sops-nix/key.txt" ]; then
    echo "Generating SOPS age key..."
    sudo nix-shell -p sops --run 'sops --generate-key > /var/lib/sops-nix/key.txt'
    sudo chmod 600 /var/lib/sops-nix/key.txt
    echo "Age key generated at /var/lib/sops-nix/key.txt"
else
    echo "Age key already exists at /var/lib/sops-nix/key.txt"
fi

echo "Setup complete!"
echo ""
echo "Now you can rebuild your configuration:"
echo "sudo nixos-rebuild switch --flake .#wsl-arifinoid"
