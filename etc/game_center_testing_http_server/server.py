# relay_server.py
from flask import Flask, request, jsonify

app = Flask(__name__)
inbox = {}  # messages per playerID
players = set()
host_player = None

@app.route('/register/<player_id>', methods=['POST'])
def register_endpoint(player_id):
    global host_player
    if player_id not in players:
        was_empty = len(players) == 0
        players.add(player_id)
        if was_empty:
            host_player = player_id
        status = 201
    else:
        status = 200
    return jsonify({
        "player": player_id,
        "host": host_player
    }), status

@app.route('/send', methods=['POST'])
def send_endpoint():
    data = request.get_json()
    recipient = data['to']
    message = data['message']
    inbox.setdefault(recipient, []).append(message)
    players.add(recipient)
    return {'status': 'OK'}, 202

@app.route('/receive/<player_id>', methods=['GET'])
def receive_endpoint(player_id):
    messages = inbox.pop(player_id, [])
    return jsonify(messages), 200

@app.route('/players', methods=['GET'])
def players_endpoint():
    return jsonify(sorted(players)), 200

@app.route('/peek/<player_id>', methods=['GET'])
def peek_endpoint(player_id):
    messages = inbox.get(player_id, [])
    return jsonify(messages), 200

@app.route('/messagecount/<player_id>', methods=['GET'])
def message_count_endpoint(player_id):
    count = len(inbox.get(player_id, []))
    return jsonify({
        # 'player': player_id,
        'count': count
    }), 200

@app.route('/messagecount', methods=['GET'])
def message_count_all_endpoint():
    count = sum(len(messages) for messages in inbox.values())
    return jsonify({
        'count': count
    }), 200

@app.route('/reset', methods=['POST'])
def reset_endpoint():
    inbox.clear()
    players.clear()
    global host_player
    host_player = None
    return jsonify({'status': 'OK'}), 200

@app.route('/resetmessages/<player_id>', methods=['POST'])
def reset_messages_endpoint(player_id):
    if player_id in inbox:
        del inbox[player_id]
    return jsonify({'status': 'OK', 'player': player_id}), 200

@app.route('/resetmessages', methods=['POST'])
def reset_messages_all_endpoint():
    inbox.clear()
    return jsonify({'status': 'OK'}), 200

@app.route('/resethost', methods=['POST'])
def reset_host_endpoint():
    global host_player
    host_player = None
    return jsonify({'status': 'OK'}), 200

@app.route('/nohost/<host>', methods=['POST'])
def nohost_endpoint(host):
    global host_player
    if host == host_player:
        host_player = None
    return jsonify({'status': 'OK'}), 200

@app.route('/host', methods=['GET'])
def host_endpoint():
    if host_player:
        return jsonify({"host": host_player}), 200
    else:
        return jsonify({}), 200

@app.route('/host/<host>', methods=['POST'])
def set_host_endpoint(host):
    global host_player
    if host not in players:
        players.add(host)
    host_player = host
    return jsonify({'status': 'OK'}), 200

@app.route('/peek', methods=['GET'])
def peek_all_endpoint():
    return jsonify(inbox), 200

@app.route('/ping', methods=['GET'])
def ping_endpoint():
    return jsonify({'status': 'OK'}), 200

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
