# Nix

Nix is a "purely functional package manager", the Nix experience is completely different than other package managers. For some people it may seem complicated to use, but it is worth it if you understood what you really need.

If you have ever used the "virtual env" tool popular in the "python" ecosystem then you can experience the same thing but across operating systems, platforms, and programming language ecosystems.

Since nix uses functional concepts like declarative then it should be utilized well. Such as declaring needs and then declaring with nix language.

## Install nix

It's great to see that you're interested in Nix. We'll get Nix installed on your system and provide you with a small taste of Nix's feature set by accomplishing some practical things, such as creating a development environment and building a package using Nix.

The installer supports these platforms:

| Platform                                                                    | Multi user?        | `root` only |
| :-------------------------------------------------------------------------- | :----------------- | :---------- |
| Linux on 64-bit ARM and 64-bit AMD/Intel (no [SELinux])                     | ✅ (via [systemd]) | ✅          |
| macOS on 64-bit ARM and 64-bit AMD/Intel                                    | ✅                 |
| [Valve Steam Deck][steamdeck] (SteamOS)                                     | ✅                 |
| [Windows Subsystem for Linux][wsl] (WSL) on 64-bit ARM and 64-bit AMD/Intel | ✅ (via [systemd]) | ✅          |
| [Podman] Linux containers                                                   | ✅ (via [systemd]) | ✅          |
| [Docker] containers                                                         |                    | ✅          |

To run the installer:

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

If you have concerns about the "curl to Bash" approach you have two options:

1. You can download a binary for the most recent version of the Determinate Nix Installer directly from the releases page and run it.
2. You can examine the installation script [here][script] then download and run it:

   ```shell
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix > nix-installer.sh
   chmod +x nix-installer.sh
   ./nix-installer.sh install
   ```

Validate the displayed plan and approve it to begin the installation process.
Once the installer has finished, you should see `Nix was installed successfully!` in your terminal.

Open a new terminal session and the `nix` executable should be in your `$PATH`.
To verify that:

```bash
nix --version
```

This should print the version information for Nix.

:rocket: **Success**!
You now have Nix installed and ready to go on your system.

Reference: <https://zero-to-nix.com/start/install>

## How to use

### update lock for specific inputs

```
# example
flake nixpkgs-unstable
```

### nix build

```bash
# ${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfigurations.${system}.${username}
# first using nix build
// https://github.com/numtide/flake-utils/blob/main/allSystems.nix

# for linux
## Build
nix build ~/.config/nixpkgs/#homeConfigurations.x86_64-linux.arifinoid.activationPackage -o ~/.config/nixpkgs/result
## Activated
~/.config/nixpkgs/result/activate switch --flake ~/.config/nixpkgs/#homeConfigurations.x86_64-linux.arifinoid

## for darwin (macos intel)
nix build ~/.config/nixpkgs/#homeConfigurations.x86_64-darwin.arifinoid.activationPackage -o ~/.config/nixpkgs/result

## for darwin (macos M1)
nix build ~/.config/nixpkgs/#homeConfigurations.aarch64-darwin.arifinoid.activationPackage -o ~/.config/nixpkgs/result

## Then you can use alias
nxa
```
