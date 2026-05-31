from flask import   Flask, jsonify
from prometheus_client import start_http_server,Counter
import time 

app = Flask(__name__)

REQUEST_COUNT = Counter('request_count', 'Total number of requests to the application')

@app.route('/')
def hello():
    REQUEST_COUNT.inc()
    return jsonify ({
        'status': 'success',
        'message': 'Welcome to the Flask application with Prometheus monitoring!',
        'timestamp': int(time.time())
    })

if __name__ == '__main__':

    start_http_server(8000)
    app.run(host='0.0.0.0', port =5000)