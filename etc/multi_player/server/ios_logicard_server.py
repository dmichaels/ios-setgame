# Simple server for my iOS Logicard (SET Game) app, for development (circa February 2026).
#
# Using nginx for multiple sites and HTTPS handling; see nginx.conf.
# Run as simple Python script (no sudo needed); see ios_logicard_server_start.sh.
# Note that our dmichaels.dev domain is registered via Squarespace.
# Note that our static AWS LightSail IP address is: 34.232.248.47
# Note that redirect from HTTP to HTTPS not needed because the .dev TLD requires HTTPS.

import argparse
from   datetime import datetime, timezone
from   flask import abort, Flask, jsonify, request
from   functools import wraps
import logging
import os
import uuid

# API Key (hardcoded!).
#
APIKEY = '.0turangalila'

# Parse arguments, setup logging, and the Flask app itself.
#
parser = argparse.ArgumentParser()
parser.add_argument('--host', type=str, default='127.0.0.1', help='Host address to bind to.')
parser.add_argument('--port', type=int, default=8001,        help='Port to bind to.')
args = parser.parse_args()
log = logging.getLogger('werkzeug') ; log.setLevel(logging.ERROR)
app = Flask(__name__)

# Global in-memory state/data.
# Lame but maybe someday we will use some kind of external database.
#
sessions = {}
hits = 0
debug = False

# Internal decorators et cetera.

def with_session(func):
    @wraps(func)
    def wrapper(session, *args, **kwargs):
        global sessions
        if (found_session := sessions.get(session)) is None:
            # For convenience (dev/testing) allow unique prefix session ID lookup.
            if len(matches := [key for key in sessions if key.startswith(session)]) != 1:
                return _nosession_response()
            found_session = sessions[matches[0]]
        return func(found_session, *args, **kwargs)
    return wrapper

def old_with_session(func):
    @wraps(func)
    def wrapper(session, *args, **kwargs):
        global sessions
        if not (found_session := sessions.get(session)):
            return _nosession_response()
        return func(found_session, *args, **kwargs)
    return wrapper

@app.before_request
def _check_api_key():
    global hits ; hits += 1
    if (request.path == '/ping') or (request.path == '/hits'):
        return
    if request.headers.get('X-API-Key') != APIKEY:
        abort(403)

# Internal utility functions/decorators.
#
def _create_session():
    global sessions
    session = str(uuid.uuid4()).replace('-', '').upper()
    if session not in sessions:
        sessions[session] = {
            'session':        session,
            'host':           None,
            'players':        [],
            'inbox':          {},
            'received_count': {},
            'queued_count':   {}
        }
    return session

# These functions to "send" specific messages to (i.e. place in the inbox of)
# players are the only situation where we coordinate closely with the iOS app;
# only comes into place for endpoints with the "_and_notify" suffix; and only
# for the (iOS) messages JoinSessionConfirmed and UpdateSession messages;
# the point being to avoid an extra roundtrip from device to server.

def _create_join_session_confirmed_message(session):
    return {'type': 'joinSessionConfirmed',
            'from': str(session['host']),
            'session': str(session['session']),
            'host': str(session['host']),
            'players': list(session['players'])}

def _create_update_session_message(session):
    return {'type': 'updateSession',
            'from': str(session['host']),
            'host': str(session['host']),
            'players': list(session['players'])}

def _send_join_session_confirmed_message(session, player):
    # Note that only the host may send this JoinSessionConfirmed message; this is enforced
    # explicitly in the JoinSessionMessage message handler in the iOS app, which calls
    # the /register_and_notify endpoint (which calls this function) ONLY if we are the host.
    join_session_confirmed_message = _create_join_session_confirmed_message(session)
    session['inbox'].setdefault(player, []).append(join_session_confirmed_message)

def _send_update_session_messages(session, excluding = []):
    # Note that only the host may send this UpdateSession message; this is enforced
    # explicitly in the JoinSessionMessage message handler in the iOS app, which
    # calls the /[un]register_and_notify endpoints (which calls this function)
    # ONLY if we are the host; also enforced by the /host_and_notify endpoint,
    # corresponding to the HostSession message in the iOS app, which calls
    # this function only if we are the (newly assigned) host.
    update_session_message = _create_update_session_message(session)
    for player in session['players']:
        if player not in excluding:
            session['inbox'].setdefault(player, []).append(update_session_message)

def _okay_response(status = 200):
    return jsonify({'status': 'OK'}), status

def _nosession_response():
    return jsonify({'status': 'nosession'}), 404

def _noplayer_response():
    return jsonify({'status': 'noplayer'}), 404

def _nohost_response(status = 404):
    return jsonify({'status': 'nohost'}), status

# The endpoints.

# Creates a new session, and registers the given player, and sets that
# player to the host within that new session; returns the session ID.
# Example Request:  POST /sessions/host
# Example Response: {"session" "DEADBEEF"}
#
@app.route('/sessions/<host>', methods=['POST'])
def create_and_host_session_endpoint(host):
    global sessions
    session = _create_session()
    sessions[session]['players'].append(host)
    sessions[session]['host'] = host
    return jsonify({'session': session}), 201

# Returns the list of defined session IDs; mostly for debugging.
# Example Request:  GET /sessions
# Example Response: ["DEADBEEF","CAFEBABE"]
#
@app.route('/sessions', methods=['GET'])
def get_sessions_endpoint():
    global sessions
    return jsonify(list(sessions.keys())), 200

# Returns ALL of the session data for the given session ID; mostly for debugging. 
# Example Request:  GET /sessions/DEADBEEF
# Example Response: {"session" "DEADBEEF", "players": ["ada", "bob"],
#                    "host": "ada", "inbox": {"ada": [{"type": "ping"}]}}
#
@app.route('/sessions/<session>', methods=['GET'])
@with_session
def get_session_endpoint(session):
    global debug
    response = {'session':        session['session'],
                'host':           session['host'],
                'players':        session['players'],
                'inbox':          session['inbox'],
                'received_count': session['received_count'],
                'queued_count':   {user: len(messages) for user, messages in session['inbox'].items()}}
    if debug:
        response.update({'debug': True, 'received_messages': session.get('received_messages')})
    return jsonify(response), 200

def old_get_session_endpoint(session):
    global debug
    if debug:
        return jsonify({'session':           session['session'],
                        'host':              session['host'],
                        'players':           session['players'],
                        'inbox':             session['inbox'],
                        'received_count':    session['received_count'],
                        'queued_count':      {user: len(messages) for user, messages in session['inbox'].items()},
                        'debug':             True,
                        'received_messages': session.get('received_messages')
           }), 200
    return jsonify({'session':  session['session'],
                    'host':     session['host'],
                    'players':  session['players'],
                    'inbox':    session['inbox'],
                    'received_count': session['received_count'],
                    'queued_count':      {user: len(messages) for user, messages in session['inbox'].items()},
           }), 200

# Resets ALL data for the given session.
# Example Request:  POST /DEADBEEF/reset
# Example Response: {"status": "OK"}
#
@app.route('/sessions/<session>/reset', methods=['POST'])
@with_session
def reset_session_endpoint(session):
    session['host'] = None
    session['players'].clear()
    session['inbox'].clear()
    return _okay_response(201)

@app.route('/sessions/<session>/destroy', methods=['POST'])
@with_session
def destroy_session_endpoint(session):
    global sessions
    if (session := session['session']) in sessions:
        del sessions[session]
    return _okay_response(201)

# Registers the given player for the given session, if not yet registered,
# or if it is already registered then do nothing; additionally in either
# case, if no host is yet defined, then sets the host to the given player.
# Example Request:  POST /DEADBEEF/register/ada
# Example Response: {"host": "ada", "player": "ada", players: ["ada", "bob"]}
#
@app.route('/<session>/register/<player>', methods=['POST'])
@with_session
def register_player_endpoint(session, player):
    if player not in session['players']:
        session['players'].append(player)
    if not session['host']:
        session['host'] = player
    return jsonify({'host':    session['host'],
                    'player':  player,
                    'players': session['players']}), 201

# Same as POST /<session>/register/<player> but also "sends" (puts in the
# inbox of) the player just registered a joinSessionConfirmed message and
# to all of the other players (except the host) an updateSession message;
# but if the player was already registered then does nothing.
# Example Request:  POST /DEADBEEF/register_and_notify/ada
# Example Response: {"host": "ada", "player": "ada", "players": ["ada", "bob"]}
#
@app.route('/<session>/register_and_notify/<player>', methods=['POST'])
@with_session
def register_player_and_notify_endpoint(session, player):
    if player not in session['players']:
        session['players'].append(player)
    if not session['host']:
        session['host'] = player
    if len(session['players']) > 1:
        _send_join_session_confirmed_message(session, player)
        _send_update_session_messages(session, excluding=[session['host']])
    return jsonify({'host':    session['host'],
                    'player':  player,
                    'players': session['players']}), 201

# Unregisters the given player for the given session.
# However if the given player is also the host then does nothing;
# i.e. cannot unregister the host; though the host can be changed
# via POST /<session>/host/<player>.
# Example Request:  POST /DEADBEEF/unregister/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/unregister/<player>', methods=['POST'])
@with_session
def unregister_player_endpoint(session, player):
    if player not in session['players']:
        return _noplayer_response()
    if player == session['host']:
        return _nohost_response(409) # not allowed to unregister host
    session['players'].remove(player)
    session['inbox'].pop(player, None)
    if session['host'] == player:
        session['host'] = None
    return _okay_response(201)

# Same as POST /<session>/unregister/<player> but also "sends" (puts
# in the inbox of) any other (non-host) players an updateSession message.
# Example Request:  POST /DEADBEEF/unregister_and_notify/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/unregister_and_notify/<player>', methods=['POST'])
@with_session
def unregister_player_and_notify_endpoint(session, player):
    if player not in session['players']:
        return _noplayer_response()
    if player == session['host']:
        return _nohost_response(409) # not allowed to unregister host
    session['players'].remove(player)
    session['inbox'].pop(player, None)
    _send_update_session_messages(session, excluding=[session['host'], player])
    return _okay_response(201)

# Returns the list of registered player IDs for the given session.
# Example Request:  GET /DEADBEEF/players
# Example Response: {"host": "ada", "players": ["ada", "bob"]}
#
@app.route('/<session>/players', methods=['GET'])
@with_session
def get_players_endpoint(session):
    return jsonify({'host':    session['host'],
                    'players': session['players']}), 200

# Returns the host for the given session.
# Example Request:  GET /DEADBEEF/host
# Example Response: {"host": "ada"}
#
@app.route('/<session>/host', methods=['GET'])
@with_session
def get_host_endpoint(session):
    return jsonify({'host': session['host']}), 200

# Sets the host to the given player, for the given session;
# if the given player is not already registered then does nothing.
# Example Request:  POST /DEADBEEF/host/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/host/<player>', methods=['POST'])
@with_session
def set_host_endpoint(session, player):
    if player not in session['players']:
        return _noplayer_response()
    session['host'] = player
    return _okay_response()

# Sets the host to the given player, for the given session;
# if the given player is not already registered then does nothing;
# and also "sends" (puts in the inbox of) a updateSession message
# to all of the players.
# Example Request:  POST /DEADBEEF/host_and_notify/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/host_and_notify/<player>', methods=['POST'])
@with_session
def set_host_and_notify_endpoint(session, player):
    if player not in session['players']:
        return _noplayer_response()
    if player != session['host']:
        session['host'] = player
        _send_update_session_messages(session)
    return _okay_response()

# Sends the given message (in the POST data) to the given player,
# for the given session; if the given player is not already
# registered then does nothing.
# Example Request:  POST /DEADBEEF/send/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/send/<player>', methods=['POST'])
@with_session
def send_message_endpoint(session, player):
    if player not in session['players']:
        return _noplayer_response()
    message = request.get_json()
    session['inbox'].setdefault(player, []).append(message)
    return _okay_response()

# Sends the given message (in the POST data) to the host player,
# for the given session; if there is no host then does nothing.
# Example Request:  POST /DEADBEEF/send
# Example Response: {"status": "OK"}
#
@app.route('/<session>/send', methods=['POST'])
@with_session
def send_host_message_endpoint(session):
    if not (host := session['host']):
        return _nohost_response()
    message = request.get_json()
    session['inbox'].setdefault(host, []).append(message)
    return _okay_response()

# Removes and returns any/all of the messages available
# for the given player, for the given session.
# Example Request:  GET /DEADBEEF/receive/ada
# Example Response: [{"type": "ping"}, {"type": "ping"}]
#
@app.route('/<session>/receive/<player>', methods=['GET'])
@with_session
def receive_messages_endpoint(session, player):
    if player not in session['players']:
        return _noplayer_response()
    messages = session['inbox'].pop(player, [])
    if len(messages) > 0:
        session['received_count'].setdefault(player, 0) ; session['received_count'][player] += len(messages);
    global debug
    if debug:
        if len(messages) > 0:
            if 'received_messages' not in session:
                session['received_messages'] = []
            # session['received_messages'].append({player: messages})
            session['received_messages'].append({
                player: {
		            'timestamp': datetime.now(timezone.utc).isoformat(),
		            'to': player,
		            'host': session['host'],
		            'players': session['players'],
		            'messages': messages
	            }
            })
    return jsonify(messages), 200

# Returns (without removal) any/all of the messages available
# for the given player, for the given session.
# Example Request:  GET /DEADBEEF/peek/ada
# Example Response: [{"type": "ping"}, {"type": "ping"}]
#
@app.route('/<session>/peek/<player>', methods=['GET'])
@with_session
def peek_messages_endpoint(session, player):
    if player not in session['players']:
        return _noplayer_response()
    messages = session['inbox'].get(player, [])
    return jsonify(messages), 200

# Clears out all message data for the given player, for the given session.
# Returns a simple status.
# Example Request:  POST /DEADBEEF/clear/ada
# Example Response: {"status": "OK"}
#
@app.route('/<session>/clear/<player>', methods=['POST'])
@with_session
def clear_player_messages_endpoint(session, player):
    if player not in session['players']:
        return _noplayer_response()
    if player in session['inbox']:
        del session['inbox'][player]
        del session['received_count'][player]
        del session['queued_count'][player]
    return _okay_response()

# Clears out all message data for ALL of the players, for the given session.
# Example Request:  POST /DEADBEEF/clear
# Example Response: {"status": "OK"}
#
@app.route('/<session>/clear', methods=['POST'])
@with_session
def clear_session_messages_endpoint(session):
    session['inbox'].clear()
    session['received_count'].clear()
    session['queued_count'].clear()
    return _okay_response()

# Resets ALL data for ALL sessions.
# Example Request:  POST /reset
# Example Response: {"status": "OK"}
#
@app.route('/reset', methods=['POST'])
def reset_endpoint():
    global sessions, debug
    sessions.clear()
    debug = False
    return _okay_response()

@app.route('/debug', methods=['GET'])
def get_debug_endpoint():
    global debug
    return {"debug": debug}

@app.route('/debug', methods=['POST'])
def set_debug_endpoint():
    global debug
    debug = True
    return _okay_response()

@app.route('/nodebug', methods=['POST'])
def set_nodebug_endpoint():
    global debug, sessions
    for session in sessions:
        if 'received_messages' in session:
            session['received_messages'].clear()
    debug = False
    return _okay_response()

# Simple ping endpoint.
# Example Request:  POST /ping
# Example Response: {"status": "OK"}
#
@app.route('/ping', methods=['GET'])
def ping_endpoint():
    return _okay_response()

@app.route('/hits', methods=['GET'])
def hits_endpoint():
    return {"hits": hits}

# Start the server!
#
if __name__ == '__main__':
    print(f'Starting iOS Logicard Backend.')
    print(f'Host: {args.host}')
    print(f'Port: {args.port}')
    app.run(host=args.host, port=args.port)
