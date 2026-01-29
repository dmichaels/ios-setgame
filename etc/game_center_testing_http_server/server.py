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

@app.route('/count/<player_id>', methods=['GET'])
def count(player_id):
    count = len(inbox.get(player_id, []))
    return jsonify({
        'player': player_id,
        'count': count
    })

@app.route('/reset', methods=['POST'])
def reset():
    inbox.clear()
    players.clear()
    global host
    host = None
    print("Server state reset.")
    return jsonify({'status': 'OK'})

@app.route('/resethost', methods=['POST'])
def reset():
    global host
    host = None
    return jsonify({'status': 'OK'})

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
