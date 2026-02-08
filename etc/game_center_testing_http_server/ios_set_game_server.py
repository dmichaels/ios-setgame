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

def with_session(func):
    @wraps(func)
    def wrapper(session, *args, **kwargs):
        global sessions
        if not (found_session := sessions.get(session)):
            return jsonify({"error": "Session error."}), 404
        return func(found_session, *args, **kwargs)
    return wrapper

# @app.route('/register/<player>', methods=['POST'])
# def register_endpoint(player):
#     global host_player
#     if player not in players:
#         was_empty = len(players) == 0
#         players.add(player)
#         if was_empty:
#             host_player = player
#         status = 201
#     else:
#         status = 200
#     return jsonify({
#         "player": player,
#         "host": host_player
#     }), status

@app.route('/session', methods=['POST'])
def session_post_endpoint():
    global sessions
    session = _uuid()
    sessions[session] = {
        'session': session,
        'players': set(),
        'host': None,
        'inbox': {}  # player_id -> [messages]
    }
    return jsonify({'session': session }), 201

@app.route('/session/<session>', methods=['GET'])
@with_session
def session_get_endpoint(session):
    return jsonify({
        'session': session['session'],
        'players': list(session['players']),
        'host':    session['host'],
        'inbox':   session['inbox']
    }), 200

@app.route('/register/<session>/<player>', methods=['POST'])
@with_session
def register_post_endpoint(session, player):
    status = 200
    was_no_players = len(session['players']) == 0
    if player not in session['players']:
        session['players'].add(player)
        status = 201
    if was_no_players or (not session['host']):
        session['host'] = player
        status = 201
    return jsonify({ "session": session['session'],
                     "player":  player,
                     "host":    session['host'] }), status


# TODO TODO TODO ...
@app.route('/send', methods=['POST'])
def send_endpoint():
    global players, host_player, inbox
    data = request.get_json()
    recipient = data['to']
    message = data['message']
    inbox.setdefault(recipient, []).append(message)
    players.add(recipient)
    return {'status': 'OK'}, 202

@app.route('/receive/<player>', methods=['GET'])
def receive_endpoint(player):
    global players, host_player, inbox
    messages = inbox.pop(player, [])
    return jsonify(messages), 200

@app.route('/players', methods=['GET'])
def players_endpoint():
    global players, host_player, inbox
    return jsonify(sorted(players)), 200

@app.route('/peek/<player>', methods=['GET'])
def peek_endpoint(player):
    global players, host_player, inbox
    messages = inbox.get(player, [])
    return jsonify(messages), 200

@app.route('/messagecount/<player>', methods=['GET'])
def message_count_endpoint(player):
    global players, host_player, inbox
    count = len(inbox.get(player, []))
    return jsonify({
        # 'player': player,
        'count': count
    }), 200

@app.route('/messagecount', methods=['GET'])
def message_count_all_endpoint():
    global players, host_player, inbox
    count = sum(len(messages) for messages in inbox.values())
    return jsonify({
        'count': count
    }), 200

@app.route('/reset', methods=['POST'])
def reset_endpoint():
    global players, host_player, inbox
    inbox.clear()
    players.clear()
    host_player = None
    return jsonify({'status': 'OK'}), 200

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
