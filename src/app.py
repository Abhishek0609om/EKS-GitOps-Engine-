from flask import Flask, render_template_string
from prometheus_client import start_http_server, Counter, Histogram
import time
import random

app = Flask(__name__)

# Advanced Telemetry Trackers
REQUEST_COUNT = Counter('request_count', 'Total requests handled by Phoenix App', ['endpoint', 'status'])
REQUEST_LATENCY = Histogram('request_latency_seconds', 'Time spent processing request', ['endpoint'])

# Beautiful modern landing page HTML string
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Phoenix Production Grid</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #0f172a; color: #f8fafc; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: #1e293b; padding: 40px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); text-align: center; max-width: 500px; border: 1px solid #334155; }
        h1 { color: #38bdf8; margin-bottom: 10px; }
        p { color: #94a3b8; font-size: 1.1rem; }
        .badge { background: #10b981; color: white; padding: 6px 12px; border-radius: 20px; font-weight: bold; font-size: 0.85rem; }
        .footer { margin-top: 20px; font-size: 0.8rem; color: #64748b; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🦅 Phoenix Application Grid</h1>
        <p>Your high-traffic GitOps cluster node is serving live requests perfectly.</p>
        <span class="badge">System Healthy</span>
        <div class="footer">Server Timestamp: {{ timestamp }}</div>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    start_time = time.time()
    
    # 🏎️ Simulate complex processing logic (like a database query)
    # This gives our load test realistic data variation
    simulated_delay = random.uniform(0.01, 0.08)
    time.sleep(simulated_delay)
    
    # Record custom telemetry
    REQUEST_COUNT.labels(endpoint='/', status='200').inc()
    REQUEST_LATENCY.labels(endpoint='/').observe(time.time() - start_time)
    
    return render_template_string(HTML_TEMPLATE, timestamp=int(time.time()))

if __name__ == '__main__':
    # Start Prometheus scraping metrics server loop on port 8000
    start_http_server(8000)
    # Start primary user traffic routing web app on port 5000
    app.run(host='0.0.0.0', port=5000)
