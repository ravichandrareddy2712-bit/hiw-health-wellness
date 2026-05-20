from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import json

app = Flask(__name__)
CORS(app)

# ============================
# LOAD KERAS MODEL
# ============================
MODEL_PATH = "model/iot_train_model.keras"
CLASS_INDEX_PATH = "model/iot_class_.json"
IMG_SIZE = 224
CONF_THRESHOLD = 0.60

model = tf.keras.models.load_model(MODEL_PATH)

with open(CLASS_INDEX_PATH, "r") as f:
    class_index = json.load(f)

# Reverse mapping: index -> label
idx_to_label = {v: k for k, v in class_index.items()}

# ============================
# PREPROCESS
# ============================
def preprocess(image_bytes):
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize((IMG_SIZE, IMG_SIZE))
    img = np.array(img, dtype=np.float32) / 255.0
    img = np.expand_dims(img, axis=0)
    return img

# ============================
# PREDICT
# ============================
@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    img_bytes = request.files["image"].read()
    input_data = preprocess(img_bytes)

    preds = model.predict(input_data)[0]
    idx = int(np.argmax(preds))
    confidence = float(preds[idx])

    if confidence < CONF_THRESHOLD:
        return jsonify({
            "label": "unknown",
            "confidence": confidence
        })

    top3 = sorted(
        [(idx_to_label[i], float(preds[i])) for i in range(len(preds))],
        key=lambda x: x[1],
        reverse=True
    )[:3]

    return jsonify({
        "label": idx_to_label[idx],
        "confidence": confidence,
        "top3": top3
    })

@app.route("/", methods=["GET"])
def health():
    return jsonify({"status": "HIW Food API running"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=7860)