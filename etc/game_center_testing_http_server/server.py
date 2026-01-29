# relay_server.py
from flask import Flask, request, jsonify

app = Flask(__name__)
inbox = {}  # messages per playerID
players = set()
host_player = None

@app.route('/register/<player_id>', methods=['POST'])
def register(player_id):
    global host_player

    was_empty = len(players) == 0
    players.add(player_id)

    if was_empty:
        host_player = player_id

    return jsonify({
        "player": player_id,
        "host": host_player
    })

@app.route('/send', methods=['POST'])
def send():
    data = request.get_json()
    print("send:")
    print(data)
    recipient = data['to']
    message = data['message']
    inbox.setdefault(recipient, []).append(message)
    players.add(recipient)
    return {'status': 'OK'}

@app.route('/receive/<player_id>', methods=['GET'])
def receive(player_id):
    messages = inbox.pop(player_id, [])
    print("receive:")
    print(messages)
    return jsonify(messages)

@app.route('/players', methods=['GET'])
def players_endpoint():
    return jsonify(sorted(players))

@app.route('/peek/<player_id>', methods=['GET'])
def peek(player_id):
    messages = inbox.get(player_id, [])
    print("peek:")
    print(messages)
    return jsonify(messages)

@app.route('/messagecount/<player_id>', methods=['GET'])
def message_count(player_id):
    count = len(inbox.get(player_id, []))
    return jsonify({
        'player': player_id,
        'count': count
    })

@app.route('/messagecount', methods=['GET'])
def message_count_all():
    count = sum(len(messages) for messages in inbox.values())
    return jsonify({
        'count': count
    })

@app.route('/reset', methods=['POST'])
def reset():
    inbox.clear()
    players.clear()
    global host_player
    host_player = None
    print("Server state reset.")
    return jsonify({'status': 'OK'})

@app.route('/resetmessages', methods=['POST'])
def reset_messages():
    inbox.clear()
    return jsonify({'status': 'OK'})

@app.route('/resethost', methods=['POST'])
def reset_host():
    global host_player
    host_player = None
    return jsonify({'status': 'OK'})

@app.route('/host', methods=['GET'])
def host_endpoint():
    if host_player:
        return jsonify({"host": host_player})
    else:
        return jsonify({})

@app.route('/host/<host>', methods=['POST'])
def set_host_endpoint(host):
    global host_player
    if host not in players:
        players.add(host)
    host_player = host
    return jsonify({'status': 'OK'})

@app.route('/peek', methods=['GET'])
def peek_all():
    return jsonify(inbox)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
