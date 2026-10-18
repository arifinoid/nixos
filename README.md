# NixOS Configuration

This is my personal NixOS configuration using flakes, home-manager, and nixvim. It includes configurations for both regular NixOS and WSL (Windows Subsystem for Linux).

## Features

- 🐧 **NixOS**: Complete system configuration with KDE Plasma desktop
- 🪟 **WSL Support**: NixOS running in Windows Subsystem for Linux
- 🏠 **Home Manager**: User environment and application configuration
- 🎨 **NixVim**: Neovim configuration with AI integration
- 🔐 **Secrets Management**: SOPS + age (multi-recipient: laptop & VPS)
- 🤖 **Agent Tooling**: `rtk` & `icm` as Nix packages, Claude Code / OpenCode / omp wired declaratively
- 🖥️ **VPS Host**: `vps` config (9router gateway + hermes-agent, no home-manager)

## Structure

```
nixos/
├── flake.nix                    # flake-parts + ez-configs
├── .sops.yaml                   # Recipient age (laptop + VPS)
├── secrets/secret.yaml          # Encrypted secrets (SOPS)
├── .config/                     # Dotfile sources (claude, opencode, omp)
├── nix/
│   ├── configurations/
│   │   ├── nixos/               # arifinoid.nix, wsl-arifinoid.nix, vps.nix
│   │   └── home/                # Home-manager config (import semua modul di bawah)
│   ├── modules/
│   │   ├── home/                # shells, git, development, agent-tools, ...
│   │   └── nixos/               # common, hardware per host, vps-disko
│   ├── packages/                # Derivasi CLI non-nixpkgs (npm-cli, agent-cli)
│   ├── scripts/                 # Skrip yang dipakai service (9router env)
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

Pakai alias biar ringkas (lihat `nix/modules/home/shells.nix`):

```bash
nxbw   # WSL   → sudo nixos-rebuild switch --flake .#wsl-arifinoid
nxb    # native→ sudo nixos-rebuild switch --flake .#arifinoid
# <vps-ip> = IP publik VPS lo (lihat shellAliases di nix/modules/home/shells.nix)
nxbv   # VPS   → nixos-rebuild switch --flake ~/Documents/repos/nixos#vps \
              #            --target-host root@<vps-ip>
svps   # ssh root@<vps-ip>
```

Tanpa alias:

```bash
sudo nixos-rebuild switch --flake .#arifinoid        # native
sudo nixos-rebuild switch --flake .#wsl-arifinoid    # WSL
nixos-rebuild switch --flake .#vps --target-host root@<vps-ip>
```

### Formatting & Lint

Formatter repo (`nixfmt`) adalah binary mentah yang butuh daftar file eksplisit —
dipanggil tanpa argumen dia membaca stdin kosong lalu error. Makanya ada alias:

```bash
nfmt   # git ls-files '*.nix' | xargs -r nix run .#formatter.x86_64-linux --
```

CI memakai `deadnix --fail` + `nixfmt --check`, jadi jalankan `nfmt` sebelum commit.

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

Semua secret pakai **SOPS + age** (pass sudah tidak dipakai).

- **Recipients** (`.sops.yaml`): `arifinoid` (laptop) + `vps`. Keduanya bisa decrypt `secrets/secret.yaml`.
- **Private key**: `/var/lib/sops-nix/key.txt` di tiap mesin (mode 0400). Jangan generate ulang setelah file dienkripsi.
- **Edit**: `sops secrets/secret.yaml`
- **Rebuild**: `nxbw` (WSL), `nxb` (native), `nxbv` (VPS)
- **Pakai**: NixOS decrypt ke `/run/secrets/<nama>` saat activation. Di VPS, `sops.templates` juga merender file persisten di `/root/...` (mis. key 9router) supaya tidak hilang saat reboot.

### Secret yang ada sekarang

| Nama | Dipakai di |
|---|---|
| `wakatime_api_key` | activity logger (semua host ber-HM) |
| `nine_router_api_key` | VPS: auth key 9router untuk hermes |

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

2. Register the secret di `sops.secrets` pada `nix/modules/nixos/common.nix`
   (modul itu di-import oleh **kedua** host laptop, WSL maupun native):

```nix
sops.secrets.<secret_name> = {
  owner = "arifinoid";
  group = "users";
  mode = "0400";
};
```

Kalau secret cuma buat VPS, daftarkan di `nix/configurations/nixos/vps.nix` (owner `root`).

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

- **Avante**: AI code assistant, provider default `copilot` (ubah di `ai/default.nix`
  kalau mau `claude`/`groq`/`grok`)
- **Claude Code**: hook `rtk` + `icm` terpasang lewat `.config/claude/settings.json`

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
- **Tanpa home-manager** — modul home tidak kepakai di sini; paket/tools dideklarasi sendiri
- Boot hybrid (grub MBR + removable EFI) karena firmware VPS ternyata BIOS legacy
- Jaringan statis via systemd-networkd (DHCP cuma dipakai cloud-init)
- **9router** sebagai systemd service, bind `127.0.0.1:20128`; API key-nya dari SOPS
- hermes-agent + rtk terpasang imperatif di `/root/.local/bin`, dibungkus script supaya
  ada di PATH system
- Alias git (`programs.git`) + alias zsh yang sama kayak laptop
- Deploy: `nxbv` (build lokal, push closure via SSH, lalu switch di VPS)

## Customization

### Adding Packages
- System packages: `nix/configurations/nixos/<host>.nix`
- User packages: modul home yang relevan di `nix/modules/home/` (`platform.nix`, `development.nix`, `agent-tools.nix`, ...)
- CLI non-nixpkgs (npm/Rust): tambah derivasi di `nix/packages/` (`npm-cli.nix`, `agent-cli.nix`)

Modul home baru **tidak perlu didaftarkan** — `nix/configurations/home/arifinoid.nix`
meng-import `lib.attrValues ezModules`, jadi semua file di `nix/modules/home/`
otomatis aktif untuk host yang memakai home-manager.

### Neovim Configuration
- Main config: `nix/nixvim/config/default.nix`
- AI (Avante, provider `copilot`): `nix/nixvim/config/ai/default.nix`
- Editor settings: `nix/nixvim/config/editor/default.nix`
- Keymaps: `nix/nixvim/config/keys.nix` (+ `navigations.nix` untuk navigasi)

## Troubleshooting

### Common Issues

1. **SOPS decryption errors**: cek `/var/lib/sops-nix/key.txt` ada & cocok recipient di `.sops.yaml`, kalau belum ada pakai `./setup-sops-key.sh`
2. **Plugin not found**: cek plugin-nya ada di nixpkgs unstable
3. **Build failures**: cek flake inputs & dependencies

### Gotchas (yang sering kepeleset)

- **File baru harus `git add` sebelum rebuild.** Flake 읽 dari git tree, jadi file
  yang belum di-track nggak ikut—even kalau referenced via `${inputs.self}`.
  Gejalanya: `path '...-source/nix/...nix' does not exist`.
- **`nix fmt` tanpa argumen gagal** (`expecting expression`) — formatter-nya binary
  mentah. Pakai alias `nfmt` yang mengoper daftar file.
- **`sops.templates` name harus relatif** (`root/...`, bukan `/root/...`). Kalau
  absolut, path default sops-nix jadi `/run/secrets/rendered//root/...` (double
  slash) dan helpernya bikin symlink file ke dirinya sendiri (ELOOP) →
  activation gagal dengan `setupSecrets failed`.
- **NixOS 25.05**: `programs.ssh.knownHosts` pakai `publicKey = "ssh-ed25519 AAAA..."`
  (baris penuh), dan `programs.ssh.extraConfig` sudah jadi string freeform.

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
