from flask import Flask, request, jsonify, g
import sqlite3
import tensorflow as tf
import numpy as np


app = Flask(__name__)


# Load AI model 
model = tf.keras.models.load_model('/home/ondul/Desktop/Leveraging-AI-Tech-for-Tomorrow-s-Solutions/lib/flaskServer/pretrained_disaster_model.h5')


DATABASE = 'disaster_alerts.db'

def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect(DATABASE)
        g.db.row_factory = sqlite3.Row
    return g.db

@app.teardown_appcontext
def close_db(e=None):
    db = g.pop('db', None)
    if db is not None:
        db.close()

@app.route('/alerts', methods=['GET'])
def get_alerts():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT type, location, severity, date FROM disasters")
    rows = cursor.fetchall()
    alerts = [{'type': r['type'], 'location': r['location'], 'severity': r['severity'], 'date': r['date']} for r in rows]
    return jsonify(alerts)

@app.route('/add_disaster', methods=['POST'])
def add_disaster():
    disaster_data = request.json
    db = get_db()
    cursor = db.cursor()
    cursor.execute(
        "INSERT INTO disasters (type, location, severity, date) VALUES (?, ?, ?, ?)",
        (disaster_data['type'], disaster_data['location'], disaster_data['severity'], disaster_data['date'])
    )
    db.commit()
    return jsonify({'message': 'Disaster added successfully!'})

if __name__ == '__main__':
    app.run(debug=True)
