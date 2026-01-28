# relay_server.py
from flask import Flask, request, jsonify

app = Flask(__name__)
inbox = {}  # messages per playerID
players = set()

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

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
