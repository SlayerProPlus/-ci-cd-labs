from flask import Flask
import os

app = Flask(__name__)

# Esto nos dirá en qué puerto está corriendo para verificar el Balanceador
puerto_actual = os.environ.get('FLASK_RUN_PORT', 'Desconocido')

@app.route('/')
def home():
    return f"¡Calculadora Python en línea! Atendiendo desde el puerto: {puerto_actual}"

if __name__ == '__main__':
    app.run(host='0.0.0.0')