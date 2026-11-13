#!/usr/bin/env bash
# Build the ADL stack locally and publish a release to the VPS.
#
# The NixOS module (nix/modules/nixos/vps-adl.nix) only declares nginx, the
# systemd units and /srv/adl/*/releases. This script fills those directories
# and flips the `current` symlink, mirroring how jobhooker/takar are deployed.
#
# Usage:
#   bash nix/scripts/deploy-adl.sh                 # api + web + file-service
#   bash nix/scripts/deploy-adl.sh api web         # only the named services
#   FILE_SERVICE_BIN=./file-service \
#     bash nix/scripts/deploy-adl.sh file-service
#
# Secrets are NOT uploaded. The services read them from /etc on the VPS, where
# sops-nix renders the files at activation (see vps-adl.nix / vps-secrets.nix):
#   /etc/adl-api.env            DATABASE_URL, JWT_SECRET, CORS_ORIGIN,
#                               FILE_SERVICE_URL
#   /etc/adl-file-service.env   R2_ACCOUNT_ID, R2_ACCESS_KEY_ID,
#                               R2_SECRET_ACCESS_KEY, R2_BUCKET_NAME,
#                               R2_PUBLIC_URL, RUST_LOG
# Do not create or edit them by hand: change secrets/secret.yaml with
# `sops secrets/secret.yaml` and rebuild the VPS.

set -euo pipefail

VPS_HOST="${VPS_HOST:-root@43.173.26.172}"
REPOS="${ADL_REPOS:-$HOME/Documents/repos}"

API_SRC="${ADL_API_SRC:-$REPOS/adl}"
WEB_SRC="${ADL_WEB_SRC:-$REPOS/adl-pwa}"
FILE_SRC="${ADL_FILE_SRC:-$REPOS/file-service}"

PUBLIC_URL="${ADL_PUBLIC_URL:-https://adl.arifinoid.web.id}"

BUN="${BUN:-bun}"
CARGO="${CARGO:-cargo}"

API_DIR=/srv/adl/api
WEB_DIR=/srv/adl/web
FILE_DIR=/srv/adl/file-service

# Keep the last N releases per service so a 40 GB disk never fills up.
KEEP_RELEASES="${KEEP_RELEASES:-5}"

# Optional: build file-service from a git ref (e.g. feat/image-upload) without
# checking it out. The temp worktree only contains tracked files, never .env.
FILE_WORKTREE=""
cleanup() {
  if [[ -n "$FILE_WORKTREE" ]]; then
    git -C "$FILE_SRC" worktree remove --force "$FILE_WORKTREE" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

remote() {
  ssh -o StrictHostKeyChecking=accept-new "$VPS_HOST" \
    "export PATH=/run/current-system/sw/bin:\$PATH; $*"
}

release_id() {
  local dir="$1" sha
  sha="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null || printf nogit)"
  printf '%s-%s' "$(date -u +%Y%m%d%H%M%S)" "$sha"
}

require_dir() {
  [[ -d "$1" ]] || die "source directory not found: $1"
}

require_remote_env() {
  remote "test -s '$1'" || die "missing $1 on $VPS_HOST (create it first, mode 0400)"
}

prune() {
  local root="$1"
  remote "ls -1dt '$root/releases/'* 2>/dev/null | tail -n +$((KEEP_RELEASES + 1)) | xargs -r rm -rf || true"
}

deploy_api() {
  require_dir "$API_SRC"
  require_remote_env /etc/adl-api.env

  local id dir
  id="$(release_id "$API_SRC")"
  dir="$API_DIR/releases/$id"

  log "API  $id"
  remote "mkdir -p '$dir'"
  # Upload only what the service needs. This is stricter than an exclude list:
  # .env, .git, .claude/.agents and test fixtures never leave this machine.
  rsync -az --no-owner --no-group --chmod=D755,F644 \
    "$API_SRC/package.json" \
    "$API_SRC/bun.lock" \
    "$API_SRC/tsconfig.json" \
    "$API_SRC/drizzle.config.ts" \
    "$VPS_HOST:$dir/"
  rsync -az --no-owner --no-group --chmod=D755,F644 "$API_SRC/src/" "$VPS_HOST:$dir/src/"

  # Install on the VPS so native deps match its platform. The lockfile is
  # uploaded, so the result is reproducible.
  remote "cd '$dir' && bun install --frozen-lockfile"
  remote "ln -sfn '$dir' '$API_DIR/current'"

  # Forward-only schema sync first; a failure aborts before the API restarts.
  remote "systemctl start adl-api-migrate.service"
  remote "systemctl restart adl-api.service"
  prune "$API_DIR"
}

deploy_web() {
  require_dir "$WEB_SRC"

  log "PWA  build (NEXT_PUBLIC_API_URL=$PUBLIC_URL)"
  ( cd "$WEB_SRC" && "$BUN" install --frozen-lockfile )

  # Regenerate OpenAPI types when the API is already reachable. On a first
  # deploy it is not, so fall back to the committed lib/api/types.ts.
  if ! ( cd "$WEB_SRC" && NEXT_PUBLIC_API_URL="$PUBLIC_URL" "$BUN" run generate-api ); then
    warn "generate-api failed, using committed lib/api/types.ts"
  fi

  ( cd "$WEB_SRC" && NEXT_PUBLIC_API_URL="$PUBLIC_URL" "$BUN" x next build --webpack )

  local id dir
  id="$(release_id "$WEB_SRC")"
  dir="$WEB_DIR/releases/$id"

  log "PWA  $id"
  remote "mkdir -p '$dir'"
  # Mirror the repo Dockerfile: .next + public + package.json + prod deps are
  # all `next start` needs. next.config.ts is already serialized into .next.
  rsync -az --no-owner --no-group --chmod=D755,F644 --exclude 'cache/' "$WEB_SRC/.next/" "$VPS_HOST:$dir/.next/"
  rsync -az --no-owner --no-group --chmod=D755,F644 "$WEB_SRC/public/" "$VPS_HOST:$dir/public/"
  rsync -az --no-owner --no-group --chmod=D755,F644 \
    "$WEB_SRC/package.json" \
    "$WEB_SRC/bun.lock" \
    "$VPS_HOST:$dir/"

  remote "cd '$dir' && bun install --frozen-lockfile --production"
  # next start writes .next/cache; the sandbox allows it only if the release is
  # owned by adl-web.
  remote "chown -R adl-web:adl-web '$dir'"
  remote "ln -sfn '$dir' '$WEB_DIR/current'"
  remote "systemctl restart adl-web.service"
  prune "$WEB_DIR"
}

deploy_file_service() {
  local bin
  if [[ -n "${FILE_SERVICE_BIN:-}" ]]; then
    bin="$FILE_SERVICE_BIN"
  elif [[ -f "$FILE_SRC/Cargo.toml" ]]; then
    log "file-service build"
    ( cd "$FILE_SRC" && "$CARGO" build --release )
    bin="$FILE_SRC/target/release/file-service"
  elif [[ -n "${ADL_FILE_REF:-}" ]]; then
    log "file-service build from $ADL_FILE_REF"
    FILE_WORKTREE="$(mktemp -u)"
    git -C "$FILE_SRC" worktree add --detach "$FILE_WORKTREE" "$ADL_FILE_REF" >/dev/null
    ( cd "$FILE_WORKTREE" && "$CARGO" build --release )
    # Move it out before the worktree is removed on exit.
    bin="$FILE_WORKTREE/file-service.release"
    cp "$FILE_WORKTREE/target/release/file-service" "$bin"
  else
    die "$FILE_SRC has no Cargo.toml; set ADL_FILE_REF=feat/image-upload or FILE_SERVICE_BIN=/path/to/file-service"
  fi
  [[ -f "$bin" ]] || die "binary not found: $bin"
  require_remote_env /etc/adl-file-service.env

  local id dir
  id="$(release_id "$FILE_SRC")"
  dir="$FILE_DIR/releases/$id"

  log "file-service  $id"
  remote "mkdir -p '$dir'"
  rsync -az --no-owner --no-group "$bin" "$VPS_HOST:$dir/file-service"
  remote "chmod 0755 '$dir/file-service' && ln -sfn '$dir' '$FILE_DIR/current'"
  remote "systemctl restart adl-file-service.service"
  prune "$FILE_DIR"
}

usage() {
  cat <<'EOF'
Deploy the ADL stack to the VPS.

  api | be          build/upload the Bun API, sync schema, restart
  web | fe          build/upload the Next.js PWA, restart
  file-service      build/upload the Rust file-service, restart
  (no arguments)    all three, in that order

Environment overrides:
  VPS_HOST          default root@43.173.26.172
  ADL_REPOS         default ~/Documents/repos
  ADL_API_SRC       default $ADL_REPOS/adl
  ADL_WEB_SRC       default $ADL_REPOS/adl-pwa
  ADL_FILE_SRC      default $ADL_REPOS/file-service
  ADL_FILE_REF      git ref to build file-service from (e.g. feat/image-upload)
  ADL_PUBLIC_URL    default https://adl.arifinoid.web.id
  FILE_SERVICE_BIN  prebuilt file-service binary (when its source is absent)
  KEEP_RELEASES     releases kept per service (default 5)
EOF
}

targets=("$@")
[[ ${#targets[@]} -gt 0 ]] || targets=(api web file-service)

for target in "${targets[@]}"; do
  case "$target" in
    api | be) deploy_api ;;
    web | fe) deploy_web ;;
    file-service | file | files) deploy_file_service ;;
    -h | --help)
      usage
      exit 0
      ;;
    *) die "unknown target: $target (use: api web file-service)" ;;
  esac
done

log "done"
