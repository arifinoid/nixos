#!/usr/bin/env bash
# Restore an existing SOPS age private key (AGE-SECRET-KEY-1...).
#
# Use this when secrets/secret.yaml is already encrypted and the machine is
# missing /var/lib/sops-nix/key.txt. setup-sops-key.sh generates a NEW key,
# which cannot decrypt secrets that were encrypted for the old key.
#
# Usage:
#   ./restore-sops-key.sh <key-file>
#   sudo cat /var/lib/sops-nix/key.txt | ./restore-sops-key.sh -
#   ./restore-sops-key.sh            # paste key, then press Ctrl-D
#
# Options:
#   -f, --force        replace an existing key (a timestamped backup is kept)
#       --skip-verify  install without testing decryption (not recommended)
#   -h, --help         show this help
#
# Env:
#   SOPS_KEY_PATH      target path (default: /var/lib/sops-nix/key.txt)

set -euo pipefail

KEY_PATH="${SOPS_KEY_PATH:-/var/lib/sops-nix/key.txt}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SECRET_FILE="$SCRIPT_DIR/secrets/secret.yaml"
SOPS_CONFIG="$SCRIPT_DIR/.sops.yaml"

FORCE=0
SKIP_VERIFY=0
SOURCE=""

usage() {
  cat <<'EOF'
Restore an existing SOPS age private key.

Usage:
  ./restore-sops-key.sh <key-file>
  sudo cat /var/lib/sops-nix/key.txt | ./restore-sops-key.sh -
  ./restore-sops-key.sh            # paste key, then Ctrl-D

Options:
  -f, --force        replace an existing key (a timestamped backup is kept)
      --skip-verify  install without testing decryption (not recommended)
  -h, --help         show this help

The key is validated and tested against secrets/secret.yaml before it is
installed to /var/lib/sops-nix/key.txt as root:root mode 0400.
EOF
}

info() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

if [[ $EUID -eq 0 ]]; then
  as_root() { "$@"; }
else
  command -v sudo >/dev/null 2>&1 || die "this script needs root and sudo was not found"
  as_root() { sudo "$@"; }
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
  -f | --force) FORCE=1 ;;
  --skip-verify) SKIP_VERIFY=1 ;;
  -h | --help)
    usage
    exit 0
    ;;
  --)
    shift
    [[ $# -le 1 ]] || die "too many arguments (try --help)"
    SOURCE="${1:-}"
    break
    ;;
  -) SOURCE="-" ;;
  -*) die "unknown option: $1 (try --help)" ;;
  *)
    [[ -z "$SOURCE" ]] || die "too many arguments (try --help)"
    SOURCE="$1"
    ;;
  esac
  shift
done

umask 077
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/restore-sops-key.XXXXXX")"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT
trap 'exit 1' INT TERM

INPUT="$TMP_DIR/input"
if [[ -z "$SOURCE" || "$SOURCE" == "-" ]]; then
  [[ -t 0 ]] && info "Paste the age secret key (AGE-SECRET-KEY-1...), then press Ctrl-D:"
  cat >"$INPUT"
else
  [[ -f "$SOURCE" ]] || die "key file not found: $SOURCE"
  [[ -r "$SOURCE" ]] || die "cannot read $SOURCE (try: sudo cat $SOURCE | $0 -)"
  cat -- "$SOURCE" >"$INPUT"
fi
[[ -s "$INPUT" ]] || die "no key received"

tr '[:lower:]' '[:upper:]' <"$INPUT" |
  grep -oE 'AGE-SECRET-KEY-1[0-9A-Z]+' >"$TMP_DIR/keys" || true

KEY_COUNT="$(wc -l <"$TMP_DIR/keys")"
[[ "$KEY_COUNT" -gt 0 ]] || die "no AGE-SECRET-KEY-1... key found in input"
[[ "$KEY_COUNT" -eq 1 ]] || warn "found $KEY_COUNT keys; using the first one"

KEY="$(head -n1 "$TMP_DIR/keys")"
if [[ ! "$KEY" =~ ^AGE-SECRET-KEY-1[QPZRY9X8GF2TVDW0S3JN54KHCE6MUA7L]{58}$ ]]; then
  die "malformed age secret key (expected AGE-SECRET-KEY-1 + 58 bech32 chars, got ${#KEY} chars)"
fi

KEY_FILE="$TMP_DIR/key.txt"
printf '%s\n' "$KEY" >"$KEY_FILE"
chmod 600 "$KEY_FILE"

derive_pubkey() {
  local file="$1"
  if command -v age-keygen >/dev/null 2>&1; then
    age-keygen -y "$file" 2>/dev/null
  elif command -v nix >/dev/null 2>&1; then
    nix shell nixpkgs#age -c age-keygen -y "$file" 2>/dev/null
  fi
}

PUBKEY="$(derive_pubkey "$KEY_FILE" || true)"

if as_root test -e "$KEY_PATH"; then
  as_root cat "$KEY_PATH" >"$TMP_DIR/existing.txt" 2>/dev/null || true
  EXISTING_KEY="$(
    tr '[:lower:]' '[:upper:]' <"$TMP_DIR/existing.txt" 2>/dev/null |
      grep -oE 'AGE-SECRET-KEY-1[0-9A-Z]+' | head -n1 || true
  )"

  if [[ -n "$EXISTING_KEY" && "$KEY" == "$EXISTING_KEY" ]]; then
    info "Key is already installed at $KEY_PATH."
    [[ -n "$PUBKEY" ]] && info "Public key: $PUBKEY"
    info "Nothing to do."
    exit 0
  fi

  if [[ $FORCE -eq 0 ]]; then
    die "$KEY_PATH already exists and does not match. Re-run with --force to replace it (a backup will be made)."
  fi
fi

if [[ $SKIP_VERIFY -eq 1 ]]; then
  warn "skipping decryption test (--skip-verify)"
else
  if [[ -n "$PUBKEY" ]]; then
    info "Public key: $PUBKEY"
    if [[ -f "$SOPS_CONFIG" ]]; then
      if grep -qF -- "$PUBKEY" "$SOPS_CONFIG"; then
        info "Recipient match: found in .sops.yaml"
      else
        warn "$PUBKEY is not listed in .sops.yaml"
      fi
    fi
  else
    warn "could not derive the public key (install age-keygen to see it)"
  fi

  if [[ -f "$SECRET_FILE" ]] && grep -q 'ENC\[' "$SECRET_FILE"; then
    sops_bin=(sops)
    if ! command -v sops >/dev/null 2>&1; then
      command -v nix >/dev/null 2>&1 ||
        die "sops not found; install sops or pass --skip-verify"
      sops_bin=(nix shell nixpkgs#sops -c sops)
    fi

    info "Testing decryption of secrets/secret.yaml..."
    if ! sops_err="$(
      SOPS_AGE_KEY_FILE="$KEY_FILE" "${sops_bin[@]}" -d "$SECRET_FILE" 2>&1 >/dev/null
    )"; then
      die "this key cannot decrypt secrets/secret.yaml: ${sops_err:-unknown sops error}"
    fi
    info "Decryption test passed."
  else
    warn "no encrypted secrets/secret.yaml found; skipping decryption test"
  fi
fi

as_root install -d -m 0700 -o root -g root "$(dirname -- "$KEY_PATH")"

if as_root test -e "$KEY_PATH"; then
  BACKUP="$KEY_PATH.bak.$(date +%Y%m%d-%H%M%S)"
  as_root cp -p -- "$KEY_PATH" "$BACKUP"
  as_root chmod 0400 -- "$BACKUP"
  info "Backed up existing key to $BACKUP"
fi

as_root install -m 0400 -o root -g root -- "$KEY_FILE" "$KEY_PATH"

info ""
info "Restored key:"
as_root stat -c '  %A %U:%G %n' -- "$KEY_PATH"
info ""
info "Next: rebuild the host that uses this key."
info "  nxb    # native arifinoid"
info "  nxbw   # WSL arifinoid"
info "  nxbv   # VPS"
info ""
info "Then verify the rendered secret:"
info "  test -s /run/secrets/wakatime_api_key && echo 'secret loaded'"
