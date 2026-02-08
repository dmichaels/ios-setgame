# Very simple server for my iOS SET Game app, for development.

import argparse
from   flask import Flask, request, jsonify
from   functools import wraps
import logging
import os
import uuid

log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)  # logging.CRITICAL to suppress almost everything

parser = argparse.ArgumentParser()
parser.add_argument("--host", default="127.0.0.1", help="Host address to bind to")
parser.add_argument("--port", type=int, default=5000, help="Port to bind to")
parser.add_argument("--cert", help="Path to SSL certificate")
parser.add_argument("--key", help="Path to SSL key")
args = parser.parse_args()

app = Flask(__name__)

# On AWS (LightSail) use:
# sudo -E nohup bash -c 'RELAY_HOST=0.0.0.0 RELAY_PORT=80 python3 ios_set_game_server.py' > ios_set_game_server.log 2>&1 &
#
server_host = os.environ.get('RELAY_HOST', '127.0.0.1')
server_port = os.environ.get('RELAY_PORT', '5000')

print(f"SERVER HOST: [{server_host}]")
print(f"SERVER PORT: [{server_port}]")
print(f"SERVER CERT: [{args.cert}]")
print(f"SERVER KEY:  [{args.key}]")

sessions = {}
players = set()
host_player = None
inbox = {}  # messages per playerID

def _uuid():
    return str(uuid.uuid4()).replace('-', '').upper()

def _create_session(session = None):
    global sessions
    session = session if session else _uuid() 
    sessions[session] = {
        'session': session,
        'players': set(),
        'host': None,
        'inbox': {}  # dictionary of player ID and list of message (dictionary)
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

# Creates a new session. Returns the new session ID.
# Example Request:  POST /session
# Example Response: {"session" "DC68C365A79640C2"}
#
@app.route('/session', methods=['POST'])
def session_post_endpoint():
    return jsonify({'session': _create_session() }), 201

# Create a new session using the given session ID, if it does not yet exist;
# if it does already exist then do nothing. Returns the session ID.
# Example Request:  POST /session/SOMEID
# Example Response: {"session" "SOMEID"}
#
@app.route('/session/<session>', methods=['POST'])
def given_session_post_endpoint(session):
    return jsonify({'session': _create_session(session) }), 201

# Returns all of the session data for the given session ID.
# Example Request:  GET /session/DC68C365A79640C2
# Example Response: {"session" "DC68C365A79640C2", "players": ["ada", "bob"],
#                    "host": "ada", "inbox": {"ada": [{"type": "ping"}]}}
#
@app.route('/session/<session>', methods=['GET'])
@with_session
def session_get_endpoint(session):
    return jsonify({
        'session': session['session'],
        'players': list(session['players']),
        'host':    session['host'] if session['host'] else '',
        'inbox':   session['inbox'],
    }), 200

# Returns the list of defined session IDs.
# Example Request:  GET /sessions
# Example Response: ["DC68C365A79640C2","3CEB398810784E4D"]
#
@app.route('/sessions', methods=['GET'])
def sessions_get_endpoint():
    global sessions
    return jsonify(list(sessions.keys())), 200

# Registers the given player ID for the given session, if not yet registered;
# if already registered then do nothing. Additionally, if no host is yet defined,
# then sets the host to the given player. Returns the session, player, and host IDs.
# Example Request:  POST /DC68C365A79640C2/register/ada
# Example Response: {"session": "DC68C365A79640C2", "player": "ada", "host": "ada"}
#
@app.route('/<session>/register/<player>', methods=['POST'])
@with_session
def register_post_endpoint(session, player):
    was_no_players = len(session['players']) == 0
    if player not in session['players']:
        session['players'].add(player)
    if was_no_players or (not session['host']):
        session['host'] = player
    return jsonify({'session': session['session'],
                    'player':  player,
                    'host':    session['host']}), 201

# Sends the given message (a dictionary in the POST data) specified by
# the "message" field of the message, to the player specified by the "to"
# field of the message, for the given session. Returns a simple status.
# Example Request:  POST /DC68C365A79640C2/register/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/send', methods=['POST'])
@with_session
def send_post_endpoint(session):
    data = request.get_json()
    to = data['to']
    message = data['message']
    session['inbox'].setdefault(to, []).append(message)
    session['players'].add(to)
    return {'status': 'OK'}, 202

# Removes and returns any/all of the messages available for the given player,
# for the given session. Returns the list of messages for the player or empty if none.
# Example Request:  GET /DC68C365A79640C2/receive/ada
# Example Response: [{"type": "ping"}, {"type": "ping"}]
#
@app.route('/<session>/receive/<player>', methods=['GET'])
@with_session
def receive_get_endpoint(session, player):
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

# Returns the list of defined player IDs for the given session ID.
# Example Request:  GET /DC68C365A79640C2/players
# Example Response: ["ada", "bob"]
#
@app.route('/<session>/players', methods=['GET'])
@with_session
def players_endpoint(session):
    return jsonify(sorted(session['players'])), 200

# Returns the number of messages available for the given player,
# for the given session. Returns a dictionary with the message count.
# Example Request:  GET /DC68C365A79640C2/messagecount/ada
# Example Response: {"count": 2}
#
@app.route('/<session>/messagecount/<player>', methods=['GET'])
@with_session
def player_message_count_endpoint(session, player):
    return jsonify({
        'count': len(session['inbox'].get(player, []))
    }), 200

# Returns the number of messages available for alls player,
# for the given session. Returns a dictionary with the message count.
# Example Request:  GET /DC68C365A79640C2/messagecount
# Example Response: {"count": 3}
#
@app.route('/<session>/messagecount', methods=['GET'])
@with_session
def message_count_endpoint(session):
    return jsonify({
        'count': sum(len(messages) for messages in session['inbox'].values())
    }), 200

# Resets ALL data for the given session ID. Returns a simple statue.
# Example Request:  POST /DC68C365A79640C2/reset
# Example Response: {"status": "OK"}
#
@app.route('/<session>/reset', methods=['POST'])
@with_session
def reset_session_endpoint(session):
    session['players'] = set()
    session['host'] = None
    session['inbox'] = {}
    return jsonify({'status': 'OK'}), 200

# Resets ALL data for ALL session. Returns a simple statue.
# Example Request:  POST /reset
# Example Response: {"status": "OK"}
#
@app.route('/reset', methods=['POST'])
def reset_endpoint():
    global sessions
    sessions = {}
    return jsonify({'status': 'OK'}), 200

# TODO
@app.route('/resetmessages/<player>', methods=['POST'])
def reset_messages_endpoint(player):
    global players, host_player, inbox
    if player in inbox:
        del inbox[player]
    return jsonify({'status': 'OK', 'player': player}), 200

@app.route('/resetmessages', methods=['POST'])
def reset_messages_all_endpoint():
    global players, host_player, inbox
    inbox.clear()
    return jsonify({'status': 'OK'}), 200

@app.route('/resethost', methods=['POST'])
def reset_host_endpoint():
    global players, host_player, inbox
    host_player = None
    return jsonify({'status': 'OK'}), 200

@app.route('/nohost/<host>', methods=['POST'])
def nohost_endpoint(host):
    global players, host_player, inbox
    if host == host_player:
        host_player = None
    return jsonify({'status': 'OK'}), 200

@app.route('/host', methods=['GET'])
def host_endpoint():
    global players, host_player, inbox
    if host_player:
        return jsonify({"host": host_player}), 200
    else:
        return jsonify({}), 200

@app.route('/host/<host>', methods=['POST'])
def set_host_endpoint(host):
    global players, host_player, inbox
    if host not in players:
        players.add(host)
    host_player = host
    return jsonify({'status': 'OK'}), 200

@app.route('/peek', methods=['GET'])
def peek_all_endpoint():
    global players, host_player, inbox
    return jsonify(inbox), 200

@app.route('/ping', methods=['GET'])
def ping_endpoint():
    return jsonify({'status': 'OK'}), 200

if __name__ == '__main__':
    # app.run(host=server_host, port=server_port, debug=False, use_reloader=False)
    app.run(host=args.host, port=args.port, ssl_context=(args.cert, args.key) if args.cert else None)
