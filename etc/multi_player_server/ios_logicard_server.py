# Simple server for my iOS SET Game (Logicard) app, for development (circa February 2026).
#
# These instructions are OBSOLETE.
# Now using nginx for multiple sites and HTTPS handling; see nginx.conf.
# Now simply run as simple Python script (no sudo needed); see ios_logicard_server.sh.
# Note that our dmichaels.dev domain is registered via Squarespace.
# Note that our static AWS LightSail IP address is: 34.232.248.47
#
# On AWS (LightSail) we use (in ios_logicard_server_start.sh) to start:
#
# sudo -E \
#   python3 ios_logicard_server.py \
#     --cert /etc/letsencrypt/live/dmichaels.dev/fullchain.pem \
#     --key  /etc/letsencrypt/live/dmichaels.dev/privkey.pem \
#     --host 0.0.0.0 \
#     --port 443 \
#       > ios_logicard_server.log 2>&1 &
#
# Note that redirect from HTTP to HTTPS not needed because the .dev TLD requires HTTPS.

import argparse
from   flask import Flask, request, jsonify
from   functools import wraps
import logging
import os
import uuid
from flask import abort


# API Key (hardcoded!).
#
APIKEY = ".0turangalila"

# Parse arguments, setup logging, and the Flask app itself.
#
parser = argparse.ArgumentParser()
parser.add_argument("--host", type=str, default="127.0.0.1", help="Host address to bind to.")
parser.add_argument("--port", type=int, default=8001,        help="Port to bind to.")
parser.add_argument("--cert", type=str, default=None,        help="Path to SSL certificate.")
parser.add_argument("--key",  type=str, default=None,        help="Path to SSL key.")
args = parser.parse_args()
log = logging.getLogger('werkzeug') ; log.setLevel(logging.ERROR)
app = Flask(__name__)

# Global in-memory state/data.
# Lame but maybe someday we will use some kind of external database.
#
sessions = {}

# Internal utility functions/decorators.
#
def _create_session(session = None):
    global sessions
    session = session if session else str(uuid.uuid4()).replace('-', '').upper()
    if session not in sessions:
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

@app.before_request
def check_api_key():
    if request.headers.get("X-API-Key") != APIKEY:
        abort(403)

# The endpoints.

# Creates a new session and returns its ID.
# Example Request:  POST /session
# Example Response: {"session" "DEADBEEF"}
#
@app.route('/session', methods=['POST'])
def create_session_endpoint():
    return jsonify({'session': _create_session()}), 201

# Create a new session using the given session ID, if it does not yet exist,
# or if it does already exist then does nothing, and returns the given session ID.
# Example Request:  POST /session/SOMEID
# Example Response: {"session" "SOMEID"}
#
@app.route('/session/<session>', methods=['POST'])
def create_given_session_endpoint(session):
    return jsonify({'session': _create_session(session) }), 201

# Returns the list of defined session IDs.
# Example Request:  GET /sessions
# Example Response: ["DEADBEEF","CAFEBABE"]
#
@app.route('/sessions', methods=['GET'])
def get_sessions_endpoint():
    global sessions
    return jsonify(list(sessions.keys())), 200

# Returns all of the session data for the given session ID.
# Example Request:  GET /session/DEADBEEF
# Example Response: {"session" "DEADBEEF", "players": ["ada", "bob"],
#                    "host": "ada", "inbox": {"ada": [{"type": "ping"}]}}
#
@app.route('/session/<session>', methods=['GET'])
@with_session
def get_session_endpoint(session):
    return jsonify({'session': session['session'],
                    'players': list(session['players']),
                    'host':    session['host'] if session['host'] else '',
                    'inbox':   session['inbox']}), 200

# Resets ALL data for the given session.
# Example Request:  POST /DEADBEEF/reset
# Example Response: {"status": "OK"}
#
@app.route('/session/<session>/reset', methods=['POST'])
@with_session
def reset_session_endpoint(session):
    session['players'].clear()
    session['host'] = None
    session['inbox'].clear()
    return jsonify({'status': 'OK'}), 200

@app.route('/session/<session>/destroy', methods=['POST'])
@with_session
def destroy_session_endpoint(session):
    global sessions
    session = session['session']
    if session in sessions:
        del sessions[session]
    return {'status': 'OK'}, 200

# Registers the given player for the given session, if not yet registered, or if
# it is already registered then do nothing; additionally, if no host is yet defined,
# then sets the host to the given player; returns the session, player, and host IDs.
# Example Request:  POST /DEADBEEF/register/ada
# Example Response: {"session": "DEADBEEF", "player": "ada", "host": "ada"}
#
@app.route('/<session>/register/<player>', methods=['POST'])
@with_session
def register_player_endpoint(session, player):
    if player not in session['players']:
        session['players'].add(player)
    if not session['host']:
        session['host'] = player
    return jsonify({'session': session['session'],
                    'player':  player,
                    'host':    session['host']}), 201

# Unregisters the given player for the given session.
# Example Request:  POST /DEADBEEF/unregister/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/unregister/<player>', methods=['POST'])
@with_session
def unregister_player_endpoint(session, player):
    session['players'].discard(player)
    session['inbox'].pop(player, None)
    if session['host'] == player:
        session['host'] = None
    return jsonify({'status': 'OK'}), 200

# Returns the list of registered player IDs for the given session.
# Example Request:  GET /DEADBEEF/players
# Example Response: {"session": "DEADBEEF", "players": ["ada", "bob"], "host": "ada"}
#
@app.route('/<session>/players', methods=['GET'])
@with_session
def get_players_endpoint(session):
    return jsonify({'session': session['session'],
                    'players': list(session['players']),
                    'host':    session['host']}), 200

# Returns the host for the given session.
# Example Request:  GET /DEADBEEF/host
# Example Response: {"session": "DEADBEEF", "host": "ada"}
#
@app.route('/<session>/host', methods=['GET'])
@with_session
def get_host_endpoint(session):
    return jsonify({'session': session['session'],
                    'host':    session['host']}), 200

# Sets the host to the given player, for the given session; if
# the given player is not already registered then also registers it.
# Example Request:  POST /DEADBEEF/host/ada
# Example Response: {"session": "DEADBEEF", "player": "ada", "host": "ada"}
#
@app.route('/<session>/host/<player>', methods=['POST'])
@with_session
def set_host_endpoint(session, player):
    if player not in session['players']:
        session['players'].add(player)
    session['host'] = player
    return jsonify({'session': session['session'],
                    'player':  player,
                    'host':    session['host']}), 201

# If the given player for the given session is the host then unsets the host.
# Example Request:  POST /DEADBEEF/unhost/ada
# Example Response: {"session": "DEADBEEF", "player": "ada", "host": "bob"}
#
@app.route('/<session>/unhost/<player>', methods=['POST'])
@with_session
def unset_host_player_endpoint(session, player):
    if player == session['host']:
        session['host'] = None
    return jsonify({'session': session['session'],
                    'player':  player,
                    'host':    session['host']}), 201

# Unsets the host for the given session.
# Example Request:  POST /DEADBEEF/unhost
# Example Response: {"status": "OK"}
#
@app.route('/<session>/unhost', methods=['POST'])
@with_session
def unset_host_endpoint(session):
    session['host'] = None
    return jsonify({'status': 'OK'}), 201

# Sends the given message (in the POST data) to the given player,
# for the given session; if the given player is not already
# registered then does nothing.
# Example Request:  POST /DEADBEEF/send/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/send/<player>', methods=['POST'])
@with_session
def send_message_endpoint(session, player):
    if player in session['players']:
        message = request.get_json()
        session['inbox'].setdefault(player, []).append(message)
    return {'status': 'OK'}, 200

# Sends the given message (in the POST data) to the host player,
# for the given session; if there is no host the does nothing.
# Example Request:  POST /DEADBEEF/send
# Example Response: {"status": "OK"}
#
@app.route('/<session>/send', methods=['POST'])
@with_session
def send_host_message_endpoint(session):
    player = session['host']
    if player:
        message = request.get_json()
        session['inbox'].setdefault(player, []).append(message)
        return {'status': 'OK'}, 200

# Removes and returns any/all of the messages available
# for the given player, for the given session.
# Example Request:  GET /DEADBEEF/receive/ada
# Example Response: [{"type": "ping"}, {"type": "ping"}]
#
@app.route('/<session>/receive/<player>', methods=['GET'])
@with_session
def receive_messages_endpoint(session, player):
    messages = session['inbox'].pop(player, [])
    return jsonify(messages), 200

# Returns (without removal) any/all of the messages available
# for the given player, for the given session.
# Example Request:  GET /DEADBEEF/peek/ada
# Example Response: [{"type": "ping"}, {"type": "ping"}]
#
@app.route('/<session>/peek/<player>', methods=['GET'])
@with_session
def peek_messages_endpoint(session, player):
    messages = session['inbox'].get(player, [])
    return jsonify(messages), 200

# Returns the number of messages available for the given player,
# for the given session. Returns a dictionary with the message count.
# Example Request:  GET /DEADBEEF/count/ada
# Example Response: {"count": 2}
#
@app.route('/<session>/count/<player>', methods=['GET'])
@with_session
def get_message_count_endpoint(session, player):
    return jsonify({'count': len(session['inbox'].get(player, []))}), 200

# Returns the number of messages available for all players,
# for the given session. Returns a dictionary with the message count.
# Example Request:  GET /DEADBEEF/count
# Example Response: {"count": 3}
#
@app.route('/<session>/count', methods=['GET'])
@with_session
def get_session_message_count_endpoint(session):
    return jsonify({'count': sum(len(messages) for messages in session['inbox'].values())}), 200

# Clears out all message data for the given player, for the given session.
# Returns a simple status.
# Example Request:  POST /DEADBEEF/clear/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/clear/<player>', methods=['POST'])
@with_session
def clear_player_messages_endpoint(session, player):
    if player in session['inbox']:
        del session['inbox'][player]
    return jsonify({'status': 'OK'}), 200

# Clears out all message data for ALL of the players, for the given session.
# Example Request:  POST /DEADBEEF/clear
# Example Response: {"status": "OK"}
#
@app.route('/<session>/clear', methods=['POST'])
@with_session
def clear_session_messages_endpoint(session):
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
    print(f"Host:        {args.host}")
    print(f"Port:        {args.port}")
    if args.cert and args.key:
        print(f"Certificate: {args.cert}")
        print(f"Private Key: {args.key}")
        app.run(host=args.host, port=args.port, ssl_context=(args.cert, args.key))
    else:
        app.run(host=args.host, port=args.port)
