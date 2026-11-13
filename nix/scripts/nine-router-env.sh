# NINE_ROUTER_API_KEY is read from the sops-rendered file
# (sops.templates in nix/modules/nixos/vps-secrets.nix).
if [ -r /root/.9router/hermes-api-key ]; then
  export NINE_ROUTER_API_KEY="$(cat /root/.9router/hermes-api-key)"
fi
