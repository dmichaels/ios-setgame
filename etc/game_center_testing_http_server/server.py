# relay_server.py
from flask import Flask, request, jsonify

app = Flask(__name__)
inbox = {}  # messages per playerID

@app.route('/send', methods=['POST'])
def send():
    data = request.get_json()
    print("send:")
    print(data)
    recipient = data['to']
    message = data['message']
    inbox.setdefault(recipient, []).append(message)
    return {'status': 'ok'}

@app.route('/receive/<player_id>', methods=['GET'])
def receive(player_id):
    messages = inbox.pop(player_id, [1,2,3])
    print("receive:")
    print(messages)
    return jsonify(messages)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
