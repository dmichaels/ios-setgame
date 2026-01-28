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

# @app.route('/players', methods=['GET'])
# def players():
#     return jsonify(list(inbox.keys()))

@app.route('/players', methods=['GET'])
def players_endpoint():
    return jsonify(sorted(players))

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
