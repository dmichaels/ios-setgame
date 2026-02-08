# Simple server for my iOS SET Game (Logicard) app, for development (circa February 2026).
#
# On AWS (LightSail) we use (in ios_set_game_server_https_dmichaels_dev.sh) to start:
#
# sudo -E \
#   python3 ios_set_game_server.py \
#     --cert /etc/letsencrypt/live/dmichaels.dev/fullchain.pem \
#     --key /etc/letsencrypt/live/dmichaels.dev/privkey.pem \
#     --host 0.0.0.0 \
#     --port 443 \
#       > ios_set_game_server_https_dmichaels_dev.log 2>&1 &
#
# The dmichaels.dev domain registered via Squarespace.
# The static (AWS LightSail) IP is: 34.232.248.47
# Note that redirect from HTTP to HTTPS not needed because the .dev TLD requires HTTPS.

import argparse
from   flask import Flask, request, jsonify
from   functools import wraps
import logging
import os
import uuid

# Logging and arguments.
#
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

parser = argparse.ArgumentParser()
parser.add_argument("--host", default="127.0.0.1", help="Host address to bind to.")
parser.add_argument("--port", type=int, default=5000, help="Port to bind to.")
parser.add_argument("--cert", help="Path to SSL certificate.")
parser.add_argument("--key", help="Path to SSL key.")
args = parser.parse_args()

# Global state/data.
#
app      = Flask(__name__)
sessions = {}

# Utility functions/decorators.
#
def _create_session(session = None):
    global sessions
    session = session if session else str(uuid.uuid4()).replace('-', '').upper()
    sessions[session] = {
        'session': session,
        'players': set(),
        'host':    None,
        'inbox':   {}
    }
    return session

def with_session(func):
    @wraps(func)
    def wrapper(session, *args, **kwargs):
        global sessions
        if not (found_session := sessions.get(session)):
            return jsonify({'error': 'Session error.'}), 404
        return func(found_session, *args, **kwargs)
    return wrapper

# The endpoints.

# Creates a new session and returns its ID.
# Example Request:  POST /session
# Example Response: {"session" "DC68C365A79640C2"}
#
@app.route('/session', methods=['POST'])
def create_session_endpoint():
    return jsonify({'session': _create_session() }), 201

# Create a new session using the given session ID, if it does not yet exist,
# or if it does already exist then does nothing, and returns the given session ID.
# Example Request:  POST /session/some-id
# Example Response: {"session" "some-id"}
#
@app.route('/session/<session>', methods=['POST'])
def create_given_session_endpoint(session):
    return jsonify({'session': _create_session(session) }), 201

# Returns the list of defined session IDs.
# Example Request:  GET /sessions
# Example Response: ["DC68C365A79640C2","3CEB398810784E4D"]
#
@app.route('/sessions', methods=['GET'])
def get_sessions_endpoint():
    global sessions
    return jsonify(list(sessions.keys())), 200

# Returns all of the session data for the given session ID.
# Example Request:  GET /session/DC68C365A79640C2
# Example Response: {"session" "DC68C365A79640C2", "players": ["ada", "bob"],
#                    "host": "ada", "inbox": {"ada": [{"type": "ping"}]}}
#
@app.route('/session/<session>', methods=['GET'])
@with_session
def get_session_endpoint(session):
    return jsonify({'session': session['session'],
                    'players': list(session['players']),
                    'host':    session['host'] if session['host'] else '',
                    'inbox':   session['inbox'],
    }), 200

# Registers the given player for the given session, if not yet registered, or if
# it is already registered then do nothing; additionally, if no host is yet defined,
# then sets the host to the given player; returns the session, player, and host IDs.
# Example Request:  POST /DC68C365A79640C2/register/ada
# Example Response: {"session": "DC68C365A79640C2", "player": "ada", "host": "ada"}
#
@app.route('/<session>/register/<player>', methods=['POST'])
@with_session
def register_player_endpoint(session, player):
    was_no_players = len(session['players']) == 0
    if player not in session['players']:
        session['players'].add(player)
    if was_no_players or (not session['host']):
        session['host'] = player
    return jsonify({'session': session['session'],
                    'player':  player,
                    'host':    session['host']}), 201

# Returns the list of registered player IDs for the given session.
# Example Request:  GET /DC68C365A79640C2/players
# Example Response: {"session": "DC68C365A79640C2", "players": ["ada", "bob"], "host": "ada"}
#
@app.route('/<session>/players', methods=['GET'])
@with_session
def get_players_endpoint(session):
    return jsonify({'session': session['session'],
                    'players': list(session['players']),
                    'host':    session['host']
    }), 200

# Returns the host for the given session.
# Example Request:  GET /DC68C365A79640C2/host
# Example Response: {"session": "DC68C365A79640C2", "host": "ada"}
#
@app.route('/<session>/host', methods=['GET'])
@with_session
def get_host_endpoint(session):
    return jsonify({'session': session['session'],
                    'host':    session['host']}), 200

# Sets the host to the given player, for the given session; if
# the given player is not already registered then also registers it.
# Example Request:  POST /DC68C365A79640C2/host/ada
# Example Response: {"session": "DC68C365A79640C2", "player": "ada", "host": "ada"}
#
@app.route('/<session>/host/<player>', methods=['POST'])
def set_host_endpoint(player):
    if player not in session['players']:
        session['players'].add(player)
    session['host'] = player
    return jsonify({'session': session['session'],
                    'player':  player,
                    'host':    session['host']
    }), 200

# If the given player for the given session is the host then unsets the host.
# Example Request:  POST /DC68C365A79640C2/unhost/ada
# Example Response: {"session": "DC68C365A79640C2", "player": "ada", "host": "bob"}
#
@app.route('/<session>/unhost/<player>', methods=['POST'])
@with_session
def unset_host_player_endpoint(session, player):
    if player == session['host']:
        session['host'] = None
    return jsonify({'session': session['session'],
                    'player':  player,
                    'host':    session['host']
    }), 200

# Unsets the host for the given session.
# Example Request:  POST /DC68C365A79640C2/unhost
# Example Response: {"status": "OK"}
#
@app.route('/<session>/unhost', methods=['POST'])
def unset_host_endpoint(session):
    session['host'] = None
    return jsonify({'status': 'OK'}), 200

# Sends the given message (in the POST data) to the given
# player, for the given session; if the given player is
# not already registered then also registers it.
# Example Request:  POST /DC68C365A79640C2/send/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/send/<player>', methods=['POST'])
@with_session
def send_player_endpoint(session, player):
    message = request.get_json()
    session['inbox'].setdefault(player, []).append(message)
    if player not in session['players']:
        session['players'].add(player)
    return {'status': 'OK'}, 202

# Removes and returns any/all of the messages available for the given player,
# for the given session. Returns the list of messages for the player or empty if none.
# Example Request:  GET /DC68C365A79640C2/receive/ada
# Example Response: [{"type": "ping"}, {"type": "ping"}]
#
@app.route('/<session>/receive/<player>', methods=['GET'])
@with_session
def receive_player_endpoint(session, player):
    messages = session['inbox'].pop(player, [])
    return jsonify(messages), 200

# Returns (without removal) any/all of the messages available for the given player,
# for the given session. Returns the list of messages for the player or empty if none.
# Example Request:  GET /DC68C365A79640C2/peek/ada
# Example Response: [{"type": "ping"}, {"type": "ping"}]
#
@app.route('/<session>/peek/<player>', methods=['GET'])
@with_session
def peek_get_endpoint(session, player):
    messages = session['inbox'].get(player, [])
    return jsonify(messages), 200

# Returns the number of messages available for the given player,
# for the given session. Returns a dictionary with the message count.
# Example Request:  GET /DC68C365A79640C2/count/ada
# Example Response: {"count": 2}
#
@app.route('/<session>/count/<player>', methods=['GET'])
@with_session
def player_message_count_endpoint(session, player):
    return jsonify({
        'count': len(session['inbox'].get(player, []))
    }), 200

# Returns the number of messages available for alls player,
# for the given session. Returns a dictionary with the message count.
# Example Request:  GET /DC68C365A79640C2/count
# Example Response: {"count": 3}
#
@app.route('/<session>/count', methods=['GET'])
@with_session
def message_count_endpoint(session):
    return jsonify({
        'count': sum(len(messages) for messages in session['inbox'].values())
    }), 200

# Clears out all message data for the given player, for the given session.
# Returns a simple status.
# Example Request:  POST /DC68C365A79640C2/clear/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/clear/<player>', methods=['POST'])
@with_session
def clear_player_messages_endpoint(session, player):
    if player in session['inbox']:
        del session['inbox'][player]
    return jsonify({'status': 'OK'}), 200

# Clears out all message data for ALL of the players, for the given session.
# Example Request:  POST /DC68C365A79640C2/clear
# Example Response: {"status": "OK"}
#
@app.route('/<session>/clear', methods=['POST'])
@with_session
def clear_session_messages_endpoint(session):
    session['inbox'].clear()
    return jsonify({'status': 'OK'}), 200

# Resets ALL data for the given session.
# Example Request:  POST /DC68C365A79640C2/reset
# Example Response: {"status": "OK"}
#
@app.route('/<session>/reset', methods=['POST'])
@with_session
def reset_session_endpoint(session):
    session['players'].clear()
    session['host'] = None
    session['inbox'].clear()
    return jsonify({'status': 'OK'}), 200

# Resets ALL data for ALL sessions.
# Example Request:  POST /reset
# Example Response: {"status": "OK"}
#
@app.route('/reset', methods=['POST'])
def reset_endpoint():
    global sessions
    sessions.clear()
    return jsonify({'status': 'OK'}), 200

# Simple ping endpoint.
# Example Request:  POST /ping
# Example Response: {"status": "OK"}
#
@app.route('/ping', methods=['GET'])
def ping_endpoint():
    return jsonify({'status': 'OK'}), 200

# Start the server!
#
if __name__ == '__main__':
    print(f"Starting iOS SET Game Backend.")
    print(f"Host: {args.host}")
    print(f"Port: {args.port}")
    print(f"Certificate: {args.cert}")
    print(f"Private Key: {args.key}")
    app.run(host=args.host, port=args.port, ssl_context=(args.cert, args.key) if args.cert else None)
