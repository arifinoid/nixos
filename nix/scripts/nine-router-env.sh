# NINE_ROUTER_API_KEY dibaca dari file yang di-render sops
# (sops.templates di nix/configurations/nixos/vps.nix).
if [ -r /root/.9router/hermes-api-key ]; then
  export NINE_ROUTER_API_KEY="$(cat /root/.9router/hermes-api-key)"
fi
