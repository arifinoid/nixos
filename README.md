# NixOS Configuration

This is my personal NixOS configuration using flakes, home-manager, and nixvim. It includes configurations for both regular NixOS and WSL (Windows Subsystem for Linux).

## Features

- 🐧 **NixOS**: Complete system configuration with KDE Plasma desktop
- 🪟 **WSL Support**: NixOS running in Windows Subsystem for Linux
- 🏠 **Home Manager**: User environment and application configuration
- 🎨 **NixVim**: Neovim configuration with AI integration
- 🔐 **Secrets Management**: SOPS + age (multi-recipient: laptop & VPS)
- 🤖 **Agent Tooling**: `rtk` & `icm` as Nix packages, Claude Code / CodeBuddy / OpenCode / omp wired declaratively
- 🖥️ **VPS Host**: `vps` config (9router gateway + hermes-agent, no home-manager)

## Structure

```
nixos/
├── flake.nix                    # flake-parts + ez-configs
├── .sops.yaml                   # age recipients (laptop + VPS)
├── secrets/secret.yaml          # Encrypted secrets (SOPS)
├── restore-sops-key.sh          # Restore existing age key (SOPS)
├── setup-sops-key.sh            # Generate new age key (re-key only)
├── .config/                     # Dotfile sources (claude, opencode, omp)
├── nix/
│   ├── configurations/
│   │   ├── nixos/               # arifinoid.nix, wsl-arifinoid.nix, vps.nix
│   │   └── home/                # Home-manager config (imports every module below)
│   ├── modules/
│   │   ├── home/                # shells, git, development, agent-tools, ...
│   │   └── nixos/               # common, hardware per host, vps-disko
│   ├── packages/                # Non-nixpkgs CLI derivations (npm-cli, agent-cli)
│   ├── scripts/                 # Scripts used by services (9router env)
│   └── nixvim/                  # Neovim (NixVim) config
└── README.md
```

## Quick Start

### Prerequisites

1. **Install NixOS** (if not already installed)
2. **Clone this repository** to your system
3. **Set up secrets** (see Secrets Management section)
4. **Enable your Cachix cache** locally: `cachix use arifinoid-nix`

### Building and Switching

Use the aliases to keep it short (see `nix/modules/home/shells.nix`):

```bash
nxbw   # WSL    → sudo nixos-rebuild switch --flake .#wsl-arifinoid
nxb    # native → sudo nixos-rebuild switch --flake .#arifinoid
# <vps-ip> = your VPS public IP (see shellAliases in nix/modules/home/shells.nix)
nxbv   # VPS    → nixos-rebuild switch --flake ~/Documents/repos/nixos#vps \
               #           --target-host root@<vps-ip>
svps   # ssh root@<vps-ip>
```

Without the aliases:

```bash
sudo nixos-rebuild switch --flake .#arifinoid        # native
sudo nixos-rebuild switch --flake .#wsl-arifinoid    # WSL
nixos-rebuild switch --flake .#vps --target-host root@<vps-ip>
```

### Formatting & Lint

The repo formatter (`nixfmt`) is a raw binary that needs an explicit file list —
called without arguments it reads empty stdin and errors. That is why there is
an alias:

```bash
nfmt   # git ls-files '*.nix' | xargs -r nix run .#formatter.x86_64-linux --
```

CI runs `deadnix --fail` + `nixfmt --check`, so run `nfmt` before committing.

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

All secrets use **SOPS + age** (pass is no longer used).

- **Recipients** (`.sops.yaml`): `arifinoid` (laptop) + `vps`. Both can decrypt `secrets/secret.yaml`.
- **Private key**: `/var/lib/sops-nix/key.txt` on each machine (mode 0400). If it is lost, restore it with `./restore-sops-key.sh`; never generate a new key after the file is encrypted.
- **Edit**: `sops secrets/secret.yaml`
- **Rebuild**: `nxbw` (WSL), `nxb` (native), `nxbv` (VPS)
- **Usage**: NixOS decrypts to `/run/secrets/<name>` at activation. On the VPS, `sops.templates` also render files under `/root/...` (e.g. the 9router key) so they survive a reboot.
- **VPS service env**: `/etc/adl-api.env`, `/etc/adl-file-service.env`, `/etc/takar.env`, `/etc/jobhooker.env` and `/etc/ask-api.env` are rendered from `secrets/secret.yaml` via `sops.templates` (symlinked to `/run/secrets/rendered/`, mode 0400 root). Do not edit them by hand: change `sops secrets/secret.yaml` and rebuild. Non-secret values (PORT, CORS, feature flags) stay in the Nix modules.

### Restore an existing key vs generate a new one

`secrets/secret.yaml` is already encrypted for the recipients in `.sops.yaml`.
If `/var/lib/sops-nix/key.txt` is lost, **restore the existing key** — do not
generate a new one, because a new key cannot decrypt existing secrets.

| Situation | Use |
|---|---|
| The key still exists on another machine / in a backup | `./restore-sops-key.sh` |
| Brand-new machine and the secrets will be re-keyed | `bash setup-sops-key.sh`, then `sops updatekeys` from a machine that can still decrypt |

#### Restoring from another machine (e.g. WSL)

On the source machine, read the key:

```bash
sudo cat /var/lib/sops-nix/key.txt
```

On the target machine (from the repo root), pipe it directly without writing it to another file:

```bash
# from a local file
./restore-sops-key.sh ~/key.txt

# from stdin / pasted input (Ctrl-D to finish)
./restore-sops-key.sh -

# straight from another machine over SSH
ssh <user>@<host> 'sudo cat /var/lib/sops-nix/key.txt' | ./restore-sops-key.sh -
```

The script will:

1. extract the `AGE-SECRET-KEY-1...` line from the input,
2. print the public key and match it against the recipients in `.sops.yaml`,
3. test decryption of `secrets/secret.yaml` before installing anything,
4. install `/var/lib/sops-nix/key.txt` as `root:root` with mode `0400`.

An existing key is not overwritten without `--force`; when overwritten, the old
version is kept as `key.txt.bak.<timestamp>`. If the installed key is identical,
the script exits without changing anything. Use `--skip-verify` only when `sops`
is unavailable (not recommended).

After restoring, rebuild and check:

```bash
nxb
test -s /run/secrets/wakatime_api_key && echo "secret loaded"
systemctl status home-manager-arifinoid.service --no-pager
```

The expected public key for the `arifinoid` recipient is:
`age1n05p386lf08e7e8h4q7065nv9enycz25hr8t4sjh6cx344l9z3ksrnnrjq`.

Never commit the private key or put it in the repo — keep it only in
`/var/lib/sops-nix/key.txt`.

### Current secrets

| Name | Used by |
|---|---|
| `wakatime_api_key` | activity logger (every host with HM) |
| `nine_router_api_key` | VPS: 9router auth key for hermes |
| `adl_database_url`, `adl_jwt_secret` | VPS: ADL API |
| `adl_r2_account_id`, `adl_r2_access_key_id`, `adl_r2_secret_access_key` | VPS: ADL file service (Cloudflare R2) |
| `takar_database_url`, `takar_migrate_database_url`, `takar_jwt_secret` | VPS: Takar API (runtime + migration) |
| `takar_fonnte_token`, `takar_brevo_api_key`, `takar_app_password` | VPS: Takar integrations |
| `jobhooker_database_url`, `jobhooker_api_token` | VPS: jobhooker |

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

2. Register the secret in `sops.secrets` in `nix/modules/nixos/common.nix`
   (that module is imported by **both** laptop hosts, WSL and native):

```nix
sops.secrets.<secret_name> = {
  owner = "arifinoid";
  group = "users";
  mode = "0400";
};
```

If the secret is only for the VPS, register it in `nix/modules/nixos/vps-secrets.nix` (owner `root`).

3. Apply configuration:

```bash
nxbw  # WSL
nxb   # native NixOS
```

SOPS decrypts the secret to `/run/secrets/<secret_name>`. Check that the file exists without printing its contents:

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

- **Avante**: AI code assistant, default provider `copilot` (change it in
  `ai/default.nix` if you want `claude`/`groq`/`grok`)
- **Claude Code**: `rtk` + `icm` hooks are installed through `.config/claude/settings.json`
- **CodeBuddy**: `rtk` + `icm` hooks are installed through `.config/codebuddy/settings.json`
  (wrapper in `nix/modules/home/codebuddy.nix`, since both only have a native
  integration for Claude Code)

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

### vps (Sumopod/Hermes, Tencent Cloud)
- **No home-manager** — the home modules are not used here; packages/tools are declared directly
- Hybrid boot (grub MBR + removable EFI) because the VPS firmware turned out to be legacy BIOS
- Static networking via systemd-networkd (DHCP is only used by cloud-init)
- hermes-agent + rtk are installed imperatively in `/root/.local/bin`, wrapped by a script so
  they are on the system PATH

## Customization

### Adding Packages
- System packages: `nix/configurations/nixos/<host>.nix`
- User packages: the relevant home module in `nix/modules/home/` (`platform.nix`, `development.nix`, `agent-tools.nix`, ...)
- Non-nixpkgs CLIs (npm/Rust): add a derivation in `nix/packages/` (`npm-cli.nix`, `agent-cli.nix`)

New home modules are **not registered manually** — `nix/configurations/home/arifinoid.nix`
imports `lib.attrValues ezModules`, so every file in `nix/modules/home/` is
automatically active for hosts that use home-manager.

### Neovim Configuration
- Main config: `nix/nixvim/config/default.nix`
- AI (Avante, provider `copilot`): `nix/nixvim/config/ai/default.nix`
- Editor settings: `nix/nixvim/config/editor/default.nix`
- Keymaps: `nix/nixvim/config/keys.nix` (+ `navigations.nix` for navigation)

## Troubleshooting

### Common Issues

1. **SOPS decryption errors** (`cannot read keyfile '/var/lib/sops-nix/key.txt'`, missing `/run/secrets/<name>`): the key is not installed or does not match the recipient in `.sops.yaml`. Restore the old key with `./restore-sops-key.sh <key-file|->` and make sure its public key is `age1n05p386...`. Do not use `setup-sops-key.sh` unless you are re-keying.
2. **Plugin not found**: check that the plugin exists in nixpkgs unstable
3. **Build failures**: check flake inputs & dependencies

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
