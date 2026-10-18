# Hermes baca key 9router dari env NINE_ROUTER_API_KEY; nilainya diambil
# dari file runtime /root/.9router/hermes-api-key (JANGAN di repo).
if [ -r /root/.9router/hermes-api-key ]; then
  export NINE_ROUTER_API_KEY="$(cat /root/.9router/hermes-api-key)"
fi
