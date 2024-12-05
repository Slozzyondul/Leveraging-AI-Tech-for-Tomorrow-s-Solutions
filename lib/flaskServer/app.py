from flask import Flask, request, jsonify, g
import sqlite3
import tensorflow as tf
import numpy as np
from flask_cors import CORS
import cv2
import torch
from PIL import Image  
import pytesseract
import os



app = Flask(__name__)
CORS(app)

# Load AI model1 
model = tf.keras.models.load_model('../flaskServer/pretrained_disaster_model.h5')

# Load the YOLOv5 model
model1 = torch.hub.load('ultralytics/yolov5', 'yolov5s')


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

@app.route('/detect', methods=['POST'])
def detect_objects():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400
    
    file = request.files['image']
    image = np.frombuffer(file.read(), np.uint8)
    image = cv2.imdecode(image, cv2.IMREAD_COLOR)

    # Perform object detection
    results = model1(image)
    detected_objects = results.pandas().xyxy[0].to_dict(orient="records")

    simplified_results = [
        {
            "name": obj['name'],
            "confidence": round(obj['confidence'], 2),
            "xmin": round(obj['xmin']),
            "ymin": round(obj['ymin']),
            "xmax": round(obj['xmax']),
            "ymax": round(obj['ymax'])
        }
        for obj in detected_objects
    ]
    
    return jsonify(simplified_results)

@app.route('/extract-text', methods=['POST'])
def extract_text():
    if 'image' not in request.files:
        return "No file provided", 400

    # Save the image locally
    image_file = request.files['image']
    image_path = os.path.join("temp", image_file.filename)
    os.makedirs("temp", exist_ok=True)  # Ensure temp directory exists
    image_file.save(image_path)

    # Use Tesseract OCR to extract text
    try:
        image = Image.open(image_path)
        extracted_text = pytesseract.image_to_string(image)
    except Exception as e:
        extracted_text = f"Error during text extraction: {str(e)}"
        print(e)

    # Clean up
    os.remove(image_path)

    return jsonify({'text': extracted_text})

if __name__ == '__main__':
    app.run(debug=True)
