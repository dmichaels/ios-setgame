sudo -E nohup bash -c 'RELAY_HOST=0.0.0.0 RELAY_PORT=80 python3 ios_set_game_server.py "$@"' > ios_set_game_server.log 2>&1 &
