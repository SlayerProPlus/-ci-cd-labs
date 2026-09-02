from flask import Flask, jsonify
import os

app = Flask(__name__)

# Variables de entorno para identificar la instancia
INSTANCE_NAME = os.environ.get('INSTANCE_NAME', 'BLUE')
INSTANCE_PORT = os.environ.get('FLASK_RUN_PORT', '8080')

@app.route('/')
def home():
    return f"¡Calculadora Python en línea! Instancia: {INSTANCE_NAME} | Puerto: {INSTANCE_PORT}"

@app.route('/health')
def health():
    return jsonify({
        "status": "ok",
        "instance": INSTANCE_NAME,
        "port": INSTANCE_PORT
    })

@app.route('/api/instance')
def instance():
    return jsonify({
        "instance": INSTANCE_NAME,
        "port": INSTANCE_PORT
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0')