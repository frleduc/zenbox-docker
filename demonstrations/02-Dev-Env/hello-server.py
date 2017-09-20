import os
from flask import Flask
app = Flask(__name__)

@app.route('/hello/<name>')
def hello_world(name):
    return 'Hello you %s!' % name

if __name__ == '__main__':
    debug = os.environ.get('DEV_MODE', False)
    app.run(host='0.0.0.0', debug=debug)
