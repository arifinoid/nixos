# NixOS Configuration

This is my personal NixOS configuration using flakes, home-manager, and nixvim. It includes configurations for both regular NixOS and WSL (Windows Subsystem for Linux).

## Features

- 🐧 **NixOS**: Complete system configuration with KDE Plasma desktop
- 🪟 **WSL Support**: NixOS running in Windows Subsystem for Linux
- 🏠 **Home Manager**: User environment and application configuration
- 🎨 **NixVim**: Neovim configuration with AI integration
- 🔐 **Secrets Management**: Both pass and SOPS for secure secret handling
- 🤖 **AI Integration**: OpenAI API integration for Neovim AI features

## Structure

```
nixos/
├── flake.nix                    # Main flake configuration
├── .sops.yaml                   # SOPS encryption configuration
├── secrets/                     # Encrypted secrets (SOPS)
├── nix/
│   ├── configurations/          # System configurations
│   │   ├── nixos/              # NixOS system configs
│   │   └── home/               # Home-manager configs
│   ├── modules/                # Reusable modules
│   └── nixvim/                 # Neovim configuration
└── README.md
```

## Quick Start

### Prerequisites

1. **Install NixOS** (if not already installed)
2. **Clone this repository** to your system
3. **Set up secrets** (see Secrets Management section)

### Building and Switching

```bash
# For regular NixOS
sudo nixos-rebuild switch --flake .#arifinoid

# For WSL
sudo nixos-rebuild switch --flake .#wsl-arifinoid
```

### Development

```bash
# Update flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Build without switching
nix build .#arifinoid
```

## Secrets Management

This configuration supports two secret management approaches:

### 1. Pass (Password Store)
- **Setup**: `pass init <gpg-key-id>`
- **Add secret**: `pass insert arifinoid/openai.api.key`
- **Usage**: `cmd:pass show arifinoid/openai.api.key` (in nixvim config)

### 2. SOPS (Secrets OPerationS)
- **Setup**: Run `./setup-sops-key.sh`
- **Edit secrets**: `sops secrets/secret.yaml`
- **Usage**: Available as environment variables

## AI Integration

The configuration includes AI-powered Neovim features:

- **Avante**: AI code assistant with multiple providers
- **Claude Code**: Claude AI integration
- **OpenAI**: GPT integration via pass or SOPS secrets

### Key Bindings
- `<leader>ca`: Open AI Ask
- `<leader>cc`: Open AI Chat  
- `<leader>ce`: Edit with instruction
- `ta`: Toggle Avante

## System Configurations

### arifinoid (Main NixOS)
- KDE Plasma desktop environment
- Full development environment
- Steam gaming support
- Bluetooth and audio configuration

### wsl-arifinoid (WSL)
- Minimal WSL-optimized configuration
- Development tools and fonts
- SSH server support
- Cross-platform compatibility

## Customization

### Adding Packages
Edit the appropriate configuration file:
- System packages: `nix/configurations/nixos/arifinoid.nix`
- User packages: `nix/modules/home/platform.nix`

### Neovim Configuration
- Main config: `nix/nixvim/config/default.nix`
- AI features: `nix/nixvim/config/ai.nix`
- Editor settings: `nix/nixvim/config/editor.nix`

## Troubleshooting

### Common Issues

1. **SOPS decryption errors**: Run `./setup-sops-key.sh` and re-encrypt secrets
2. **Plugin not found**: Check if plugin exists in nixpkgs unstable
3. **Build failures**: Check flake inputs and dependencies

### Getting Help

- Check NixOS manual: `nixos-help`
- Search packages: `nix search <package-name>`
- Check flake inputs: `nix flake show`

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixVim Documentation](https://github.com/nix-community/nixvim)
- [SOPS Documentation](https://github.com/mozilla/sops)

## Inspiration

This configuration was inspired by these excellent NixOS setups:

- **[malob/nixpkgs](https://github.com/malob/nixpkgs)** - A comprehensive Nix configuration with flakes, home-manager, and nix-darwin support.
- **[r17x/universe](https://github.com/r17x/universe)** - A development universe. Includes AI integration, secrets management with SOPS, and modern development tooling.
