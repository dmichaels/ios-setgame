# No longer used with dmichaels.dev which defaults to and must be https.

from flask import Flask, redirect, request

app = Flask(__name__)

@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def redirect_to_https(path):
    return redirect(f"https://{request.host}{request.full_path}", code=301)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
