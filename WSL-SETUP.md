# NixOS-WSL Setup Guide

This guide will help you configure your NixOS-WSL machine to use your existing `arifinoid` flake configuration.

## What's Been Added

### 1. WSL Hardware Configuration (`nix/modules/nixos/wsl-hardware.nix`)
- Minimal configuration since NixOS-WSL handles most WSL specifics
- Sets up WSL-specific environment variables
- Configures platform settings for x86_64-linux

### 2. WSL NixOS Configuration (`nix/configurations/nixos/wsl-arifinoid.nix`)
- Imports the WSL hardware configuration
- Includes essential development tools and packages
- Configures WSL-specific user settings
- Sets up WSL-appropriate services

### 3. Updated Flake Configuration
- Added `wsl-arifinoid` as a new host in your ez-configs setup
- Maintains compatibility with your existing desktop configuration

## Prerequisites

Before proceeding, ensure you have:

1. **NixOS-WSL installed**: Follow the [official NixOS-WSL installation guide](https://github.com/nix-community/NixOS-WSL)
2. **Flakes enabled**: Add to `/etc/nix/nix.conf`:
   ```
   experimental-features = nix-command flakes
   ```
3. **Git access**: To clone your configuration repository

## Setup Steps

### Option 1: Using the Setup Script (Recommended)

1. **Copy the setup script** to your NixOS-WSL machine:
   ```bash
   # From Windows, copy setup-wsl.sh to your WSL environment
   cp /mnt/c/Users/Arif\ Kiki/Documents/personal/nixos/setup-wsl.sh ~/
   ```

2. **Make it executable and run**:
   ```bash
   chmod +x ~/setup-wsl.sh
   ~/setup-wsl.sh
   ```

### Option 2: Manual Setup

1. **Clone your configuration**:
   ```bash
   sudo mkdir -p /etc/nixos
   cd /etc/nixos
   sudo git clone <your-repo-url> nixos
   cd nixos
   ```

2. **Build the configuration**:
   ```bash
   sudo nixos-rebuild build --flake .#wsl-arifinoid
   ```

3. **Apply the configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .#wsl-arifinoid
   ```

## Configuration Details

### What's Different from Desktop

- **No GUI**: X11, Plasma, and desktop services are disabled
- **WSL-optimized**: Leverages NixOS-WSL's built-in WSL optimizations
- **Development-focused**: Includes essential development tools and language servers
- **Lightweight**: Removes heavy desktop applications and services

### What's Preserved

- **User configuration**: Same user (`arifinoid`) with similar settings
- **Development tools**: Your custom nixvim, language servers, and development packages
- **Shell configuration**: Fish shell, tmux, starship, and zoxide
- **Package management**: Nix-based package management with flakes

## Available Commands

After setup, you can use:

- **Build configuration**: `sudo nixos-rebuild build --flake .#wsl-arifinoid`
- **Dry run**: `sudo nixos-rebuild dry-activate --flake .#wsl-arifinoid`
- **Apply changes**: `sudo nixos-rebuild switch --flake .#wsl-arifinoid`
- **Test configuration**: `sudo nixos-rebuild test --flake .#wsl-arifinoid`

## Troubleshooting

### Common Issues

1. **Flake not found**: Ensure you're in the correct directory (`/etc/nixos/nixos`)
2. **Build failures**: Check that all dependencies are available in your flake inputs
3. **Permission errors**: Ensure you're running commands with `sudo`

### Getting Help

- Check NixOS logs: `journalctl -u nixos-rebuild`
- Verify flake: `nix flake show`
- Check configuration: `nixos-rebuild dry-activate --flake .#wsl-arifinoid`

## Next Steps

After successful setup:

1. **Customize**: Modify `wsl-arifinoid.nix` to add/remove packages as needed
2. **Sync**: Keep your configuration in sync with your main repository
3. **Extend**: Add WSL-specific modules and configurations as needed

## Files Structure

```
nix/
├── configurations/nixos/
│   ├── arifinoid.nix          # Desktop configuration
│   └── wsl-arifinoid.nix      # WSL configuration (NEW)
├── modules/nixos/
│   ├── arifinoid-hardware.nix # Desktop hardware
│   └── wsl-hardware.nix       # WSL hardware (NEW)
└── default.nix                 # Updated with WSL host
```

Your WSL NixOS machine is now ready to use your `arifinoid` configuration! 🎉

