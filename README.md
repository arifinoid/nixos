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
4. **Enable your Cachix cache** locally: `cachix use arifinoid-nix`

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
- **Create or restore age key**: Keep private key at `/var/lib/sops-nix/key.txt`.
- **Edit secrets**: `sops secrets/secret.yaml`
- **Rebuild**: `nxbw` for WSL or `nxb` for native NixOS.
- **Usage**: NixOS decrypts secrets into `/run/secrets/` during activation.

Never generate a new age key after encrypting `secrets/secret.yaml`. The private key must match the recipient in `.sops.yaml`.

### Add an API key

Use one secret name per API key. Replace `<secret_name>` with a lowercase name such as `openai_api_key`.

1. Add the key to encrypted SOPS data:

```bash
sops secrets/secret.yaml
```

Add this field in the editor:

```yaml
<secret_name>: paste-api-key-here
```

2. Register the secret in both NixOS configurations under `sops.secrets`:

```nix
<secret_name> = {
	owner = "arifinoid";
	group = "users";
	mode = "0400";
};
```

Add the block to both:

- `nix/configurations/nixos/wsl-arifinoid.nix`
- `nix/configurations/nixos/arifinoid.nix`

3. Apply configuration:

```bash
nxbw  # WSL
nxb   # native NixOS
```

SOPS decrypts the key to `/run/secrets/<secret_name>`. Check file existence without printing the key:

```bash
test -s /run/secrets/<secret_name> && echo "secret loaded"
```

### Use secret in OpenCode

OpenCode supports file substitution. Reference the decrypted file in `.config/opencode/opencode.json`:

```json
"apiKey": "{file:/run/secrets/<secret_name>}"
```

Do not commit API keys, plaintext secret files, shell exports, or generated `/run/secrets` files.

### OpenCode configuration

Home Manager links `.config/opencode/opencode.json` to `~/.config/opencode/opencode.json` during rebuild. Do not edit the generated path directly.

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
