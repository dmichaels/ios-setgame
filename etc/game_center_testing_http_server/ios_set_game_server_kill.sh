#!/bin/bash

# Find the parent process for ios_set_game_server.py
pids=$(ps aux | grep '[i]os_set_game_server.py' | awk '{print $2}')

if [ -z "$pids" ]; then
    echo "No ios_set_game_server.py processes found."
    exit 0
fi

echo "Killing the following PIDs related to ios_set_game_server.py: $pids"
for pid in $pids; do
    # Kill the full process tree rooted at this PID
    echo "Killing PID $pid and any children..."
    pkill -TERM -P $pid 2>/dev/null
    kill -TERM $pid 2>/dev/null
done

echo "Done."
