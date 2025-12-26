# SafeRoute 🛣️✨  
### Safety-Aware Navigation Using AI and Google Maps

SafeRoute is a mobile-first navigation system that evaluates **how safe a route is**, not just how fast it is. Traditional navigation systems optimize for distance or time; SafeRoute AI augments routing with **context-aware safety analysis** using Google Maps data, computer vision, and explainable backend logic.

---

## 🚩 Problem Statement

Navigation apps often recommend:
- Dark residential shortcuts at night
- Isolated service roads
- Poorly lit or low-activity areas

These routes may be *fast*, but not *safe*, especially for:
- Women
- Students
- Late-night commuters

There is no widely available system that answers:

> **“Is this route safe to take right now?”**

---

## 💡 Solution Overview

SafeRoute evaluates **route safety probabilistically** by combining:
- Street-level visual understanding (ML)
- Urban activity likelihood
- Time-of-day considerations
- Road context

The system returns:
- A **safety score (0–100)**
- A **risk category (LOW / MEDIUM / HIGH)**
- **Human-readable explanations**
- Route geometry for map rendering

---

## 🧠 System Architecture

```
Flutter App
|
| (Authenticated request with coordinates)
↓
Go Backend (Gin)
|
|-- Google Directions API (route geometry)
|-- Polyline decoding & segmentation
|-- Google Street View API (visual context)
|-- Google Places API (activity likelihood)
|-- ML Inference (Vertex AI)
|
↓
Safety Scoring & Explanation Engine
↓
Flutter UI (route + explanations)
```

---

## 📱 Frontend (Flutter)

### Responsibilities
- Authenticate users via Firebase Authentication
- Collect origin and destination
- Call backend `/analyze-route` endpoint
- Render route polyline on Google Maps SDK
- Display safety score, risk level, and explanations

### Map Rendering
- Uses **encoded polyline** returned by backend
- Decodes and draws route using Google Maps Flutter SDK
- Colour-coded routes based on estimated risk level

---

## 🔐 Authentication

- Firebase Authentication (Email/Password)
- Flutter obtains a Firebase ID Token
- Backend verifies token using Firebase Admin SDK
- All route analysis endpoints are protected

---

## ⚙️ Backend (Go + Gin)

The backend acts as the **orchestrator** and **decision layer**.

---

### 1️⃣ Route Fetching (Google Directions API)

- Backend requests Directions API with origin & destination
- Retrieves:
  - Total distance & duration
  - Encoded polyline representing the route geometry
- Supports future extension to alternative routes

---

### 2️⃣ Polyline Decoding & Route Segmentation

- Encoded polyline is decoded into `(lat, lng)` points
- Routes often contain hundreds of points
- To control cost and latency:
  - Route is sampled every ~400–600 meters
  - Typically results in **5–10 representative segments**

Each segment represents a location where safety is evaluated.

---

### 3️⃣ Street View Image Retrieval

For each segment:
- Backend constructs a **Street View Static API URL**
- Images are not downloaded or stored
- URLs are passed to the ML service

This provides **human-perspective visual context**.

---

### 4️⃣ Activity Likelihood (Google Places API)

To estimate how “busy” an area is:
- Backend queries Nearby Places API around each segment
- Counts POIs such as:
  - Shops
  - Cafes
  - Transit stations
  - Restaurants

This yields an **ActivityLikelihoodScore**, a proxy for human presence — especially important at night when Street View images may be outdated.

---

### 5️⃣ Time-of-Day Risk Modeling

Street View images are static and often captured during daytime.

To address this:
- Backend explicitly models time-based risk
- Night-time routes are penalized
- Day-time routes receive lower risk penalties

This ensures honest handling of temporal uncertainty.

---

## 🤖 Machine Learning Pipeline

> **ML estimates probabilistic indicators — not safety itself.**

### ML Pipeline Overview (SafeRoute AI)

The ML pipeline estimates probabilistic indicators, not safety itself. Given a street-level image (base64-encoded), the system runs a multi-stage inference flow:

- **YOLOv8** extracts interpretable object features (people, vehicles, traffic lights)
- **SegFormer** estimates structural context (buildings, sidewalks, poles, vegetation)

These features are aggregated into a compact vector.

Since no ground-truth labels exist for concepts like crowd persistence or lighting adequacy, heuristic-driven **pseudo-labeling** is used. Domain-informed equations convert extracted features into continuous probabilistic proxy labels.

Lightweight regression models are trained on this pseudo-labeled data to learn smoother, more generalizable probability mappings, reducing sensitivity to handcrafted thresholds.

At inference, the ML pipeline outputs:
- `crowd_score`
- `lighting_score`

Time-aware adjustments and final safety reasoning are handled **outside ML** in the backend.

The ML service is:
- Exposed via **FastAPI**
- Containerized with **Docker**
- Deployed as a **Vertex AI custom prediction endpoint**

---

## 🧮 Safety Scoring Logic (Backend)

### Segment-Level Safety Score

Each segment receives a safety score computed as:
```
SegmentSafetyScore =
0.30 × LightingScore
0.25 × CrowdScore
0.20 × ActivityLikelihoodScore
0.15 × TimeOfDayScore
0.10 × RoadTypeScore
```

---

### Route-Level Safety Aggregation

Routes are only as safe as their weakest segment:
```
RouteSafetyScore =
0.6 × Average(SegmentSafetyScores)
0.4 × Minimum(SegmentSafetyScores)
```

---

### Risk Classification

| Score | Risk Level |
|-----|-----------|
| ≥ 70 | LOW |
| 40–69 | MEDIUM |
| < 40 | HIGH |

---

## 🗣️ Explainability (Key Feature)

Instead of returning only a numeric score, the backend generates **human-readable explanations** based on aggregated signals:

- Mostly well-lit streets
- Moderate likelihood of human activity
- Some people likely present
- Night-time increases risk
- Mostly residential roads

These explanations are returned alongside the score and displayed directly in the app.

---

## 📦 API Response Example

```json
{
  "route": {
    "encoded_polyline": "...",
    "distance_km": 0.47,
    "duration_min": 3,
    "safety_score": 62,
    "risk_level": "MEDIUM",
    "explanations": {
      "lighting": "Mostly well-lit streets",
      "activity": "Moderate likelihood of human activity",
      "crowd": "Some people likely present",
      "time_of_day": "Night-time increases risk",
      "road_type": "Mostly residential roads"
    }
  },
  "segments": []
}
```

Future Improvements:

- Historical crime data integration
- Gemini based chat for in-depth safety explanations
- User preference tuning for commonly used routes 
- User reported safety scores for segments/routes
