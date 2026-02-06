sudo -E RELAY_HOST=0.0.0.0 RELAY_PORT=443 \
  python3 ios_set_game_server.py \
    --cert /etc/letsencrypt/live/dmichaels.dev/fullchain.pem \
    --key /etc/letsencrypt/live/dmichaels.dev/privkey.pem \
    --host 0.0.0.0 \
    --port 443 \
      > ios_set_game_server_https_dmichaels_dev.log 2>&1 &
