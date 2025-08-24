#!/bin/bash

# WSL NixOS Setup Script for arifinoid configuration
# Minimal setup script that avoids network issues

set -e

echo "🚀 Setting up NixOS-WSL with arifinoid configuration..."

# Check if we're running in WSL
if [[ ! -f /proc/version ]] || ! grep -qi microsoft /proc/version; then
    echo "❌ This script is designed to run in WSL. Please run it from your WSL NixOS environment."
    exit 1
fi

# Check if we're running NixOS-WSL
if ! grep -qi "nixos" /etc/os-release; then
    echo "❌ This script is designed to run on NixOS-WSL."
    echo "   Please install NixOS-WSL first: https://github.com/nix-community/NixOS-WSL"
    exit 1
fi

# Check if flake is enabled
if ! nix flake --version &> /dev/null; then
    echo "❌ Nix flakes are not enabled. Please enable them first:"
    echo "   echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf"
    exit 1
fi

# Install git if not available (needed for flake operations)
if ! command -v git >/dev/null 2>&1; then
    echo "📦 Installing git (required for flake operations)..."
    sudo nix-env -i git
fi

echo "✅ Prerequisites check passed"

# Create configuration directory if it doesn't exist
sudo mkdir -p /etc/nixos

# Copy your flake configuration
echo "📁 Setting up flake configuration..."
if [ -d "/mnt/c/Users/Arif Kiki/Documents/personal/nixos" ]; then
    echo "   Found configuration in Windows directory"
    sudo cp -r "/mnt/c/Users/Arif Kiki/Documents/personal/nixos" /etc/nixos/
    cd /etc/nixos/nixos
    
    # Copy the generated hardware configuration
    echo "   Copying generated hardware configuration..."
    sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
    
    # Fix Git repository ownership
    echo "   Fixing Git repository ownership..."
    sudo chown -R root:root .git/ 2>/dev/null || true
    sudo chown -R root:root . 2>/dev/null || true
    
    # Remove Git remote to avoid ownership issues
    echo "   Removing Git remote to avoid ownership issues..."
    sudo git remote remove origin 2>/dev/null || true
else
    echo "   Configuration not found in expected Windows location"
    echo "   Please copy your nixos configuration to /etc/nixos/nixos"
    echo "   Then run: cd /etc/nixos/nixos"
    exit 1
fi

# Build the configuration (offline mode to avoid network issues)
echo "🔨 Building NixOS configuration (offline mode)..."
echo "   Using minimal configuration to avoid build dependencies..."
sudo nixos-rebuild build --flake .#wsl-arifinoid --option substitute false

echo "✅ Configuration built successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Review the configuration: sudo nixos-rebuild dry-activate --flake .#wsl-arifinoid"
echo "2. Apply the configuration: sudo nixos-rebuild switch --flake .#wsl-arifinoid"
echo "3. Reboot if necessary: sudo reboot"
echo ""
echo "🎉 Your NixOS-WSL machine is now configured with your arifinoid setup!"

