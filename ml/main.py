from fastapi import FastAPI
from pydantic import BaseModel
import base64
import io

import numpy as np
import torch
import joblib
from PIL import Image

from ultralytics import YOLO
from transformers import (
    SegformerImageProcessor,
    SegformerForSemanticSegmentation
)

app = FastAPI(title="AI Inference")

yolo_model = YOLO("models/yolov8n.pt")

crowd_model = joblib.load("models/crowd_model.joblib")
lighting_model = joblib.load("models/lighting_model.joblib")

seg_processor = SegformerImageProcessor.from_pretrained("models/segformer_model")
seg_model = SegformerForSemanticSegmentation.from_pretrained("models/segformer_model")
seg_model.eval()

class PredictRequest(BaseModel):
    image_base64: str

def decode_image(image_base64: str) -> np.ndarray:
    image_bytes = base64.b64decode(image_base64)
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    return np.array(img)

def safe_ratio(x, eps=1e-6):
    return float(np.clip(x, eps, 1.0 - eps))

def sigmoid(x):
    return float(1 / (1 + np.exp(-x)))

def extract_yolo_features(img_np: np.ndarray) -> dict:
    result = yolo_model.predict(
        source=[img_np],
        imgsz=640,
        device="cpu",
        verbose=False
    )[0]

    person_count = 0
    vehicle_count = 0
    traffic_light_count = 0
    detected_classes = set()

    if result.boxes is not None:
        for cls_id in result.boxes.cls.tolist():
            cls_name = yolo_model.names[int(cls_id)]
            detected_classes.add(cls_name)

            if cls_name == "person":
                person_count += 1
            elif cls_name in ["car", "bus", "truck", "motorbike", "bicycle"]:
                vehicle_count += 1
            elif cls_name == "traffic light":
                traffic_light_count += 1

        total_objects = len(result.boxes.cls)
    else:
        total_objects = 0

    return {
        "person_count": person_count,
        "vehicle_count": vehicle_count,
        "traffic_light_count": traffic_light_count,
        "total_object_count": total_objects,
        "any_person_present": int(person_count > 0),
        "any_vehicle_present": int(vehicle_count > 0),
        "object_diversity": len(detected_classes),
    }

def extract_segmentation_features(img_pil: Image.Image) -> dict:
    inputs = seg_processor(images=img_pil, return_tensors="pt")

    with torch.no_grad():
        outputs = seg_model(**inputs)

    seg_pred = outputs.logits.argmax(dim=1).squeeze().cpu().numpy()
    total_pixels = seg_pred.size

    return {
        "building_ratio": safe_ratio((seg_pred == 2).sum() / total_pixels),
        "sidewalk_ratio": safe_ratio((seg_pred == 1).sum() / total_pixels),
        "pole_ratio": safe_ratio((seg_pred == 5).sum() / total_pixels),
        "vegetation_ratio": safe_ratio((seg_pred == 8).sum() / total_pixels),
    }
def run_pipeline(img_np: np.ndarray) -> dict:
    img_pil = Image.fromarray(img_np)

    features = {
        **extract_yolo_features(img_np),
        **extract_segmentation_features(img_pil)
    }

    # Prepare inputs (1 x n_features) for the scikit-learn models using NumPy
    crowd_X = np.array([[
        features["person_count"],
        features["vehicle_count"],
        features["any_person_present"],
        features["any_vehicle_present"],
        features["sidewalk_ratio"],
        features["building_ratio"],
        features["object_diversity"],
    ]])

    lighting_X = np.array([[
        features["traffic_light_count"],
        features["pole_ratio"],
        features["building_ratio"],
        features["sidewalk_ratio"],
        features["total_object_count"],
        features["vegetation_ratio"],
    ]])

    crowd_raw = crowd_model.predict(crowd_X)[0]
    light_raw = lighting_model.predict(lighting_X)[0]

    return {
        "crowd_score": round(sigmoid(crowd_raw), 3),
        "lighting_score": round(sigmoid(light_raw), 3),
    }


@app.post("/predict")
def predict(request: PredictRequest):
    img_np = decode_image(request.image_base64)
    return run_pipeline(img_np)
