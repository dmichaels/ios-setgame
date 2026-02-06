sudo -E RELAY_HOST=0.0.0.0 RELAY_PORT=443 \
  python3 ios_set_game_server.py \
    --cert /etc/letsencrypt/live/dmichaels.org/fullchain.pem \
    --key /etc/letsencrypt/live/dmichaels.org/privkey.pem \
    --host 0.0.0.0 \
    --port 443 \
      > ios_set_game_server_https.log 2>&1 &
