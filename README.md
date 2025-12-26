# SafeRoute 🛣️
### Safety-Aware Navigation Using AI and Google Maps

SafeRoute is a mobile-first navigation system that evaluates **how safe a route is**, not just how fast it is. Traditional navigation systems optimize for distance or time; SafeRoute augments routing with **context-aware safety analysis** using Google Maps data, computer vision, and explainable backend logic.

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
- Available routes as provided by google maps
- **safety score (0–100)** per route
- Segment wise scores of safety indicators
- A **risk category (LOW / MEDIUM / HIGH)**
- **Human-readable explanations**
- Route geometry for map rendering

---

## 🧠 System Architecture

```
Flutter App
│
│  (Authenticated request with origin & destination)
↓
Go Backend (Google Cloud Run)
│
│-- Google Directions API fetches available routes and route geometry
│-- Encoded polylines are decoded and routes are segmented every ~500m
│
│   For each route segment:
│
│-- Google Street View API provides street-level visual context
│   (Base64 encoding of the streetview image passed to ML service)
↓
ML Service (Google Cloud Run)
│
│-- YOLOv8 extracts object-level features (people, vehicles, traffic signals)
│-- SegFormer estimates structural context (buildings, sidewalks, street lights)
│-- Heuristic-driven pseudo-labeling converts features into probabilistic proxies
│-- Lightweight regression models output:
│     • Crowd Likelihood Score
│     • Lighting Infrastructure Score
│
↓
Go Backend (Google Cloud Run)
│
│-- Road type is inferred using Google Roads & Places API step metadata
│-- Google Places API estimates activity likelihood from nearby POIs (~100m radius)
│-- Time-of-day risk adjustment is applied
│-- Segment safety score is computed
│
↓
Segment scores are aggregated using average + worst-case weighting
↓
Final route safety score, risk level, and explanations are returned
↓
Flutter App renders routes and displays safety insights
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
  - Available routes between the two points 
  - Total distance & duration
  - Encoded polyline representing the route geometry

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
- Backend calculates the direction in which the road points for the segment
- Constructs a **Street View Static API URL** using those calculations
- Images are converted into base64 encoded strings which are passed to the ML service

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

This yields an **ActivityLikelihoodScore**, a proxy for human presence - especially important at night when Street View images may be outdated.

---

### 5️⃣ Time-of-Day Risk Modeling

Street View images are static and often captured during daytime.

To address this:
- Backend explicitly models time-based risk
- Night-time routes are penalized
- Day-time routes receive lower risk penalties

This ensures honest handling of temporal uncertainty.

---

### 6️⃣ Road Type Risk Modeling

Road context significantly affects perceived safety, especially during off-peak hours.

To incorporate this:
- The backend infers road type using **Google Directions API step metadata**, such as road names and maneuver context
- Roads are categorized into broad classes (e.g., main roads, residential roads, service roads)
- Less-traveled and residential roads receive higher risk penalties compared to main or arterial roads

By explicitly modeling road type, the system avoids assuming that all navigable roads are equally safe adding to the safety assessment.

---

## 🤖 Machine Learning Pipeline

> **ML estimates probabilistic indicators — not safety itself.**

### ML Pipeline Overview (SafeRoute)

The ML pipeline estimates probabilistic indicators, not safety itself. Given a street-level image (base64-encoded), the system runs a multi-stage inference flow:

- **YOLOv8** extracts interpretable object features (people, vehicles, traffic lights)
- **SegFormer** estimates structural context (buildings, sidewalks, poles)

These features are aggregated into a compact vector.

Since no ground-truth labels exist for concepts like crowd persistence or lighting adequacy, heuristic-driven **pseudo-labeling** is used. Domain-informed equations convert extracted features into continuous probabilistic proxy labels.

Lightweight regression models are trained on this pseudo-labeled data to learn smoother, more generalizable probability mappings, reducing sensitivity to handcrafted thresholds.

At inference, the ML pipeline outputs:
- `crowd_score`
- `lighting_score`

The ML service is:
- Exposed via **FastAPI**
- Containerized with **Docker**
- Deployed as a **Google cloud run service**

---

## 🧮 Safety Scoring Logic (Backend)

### Segment-Level Safety Score

Each segment receives a safety score computed as:
```
SegmentSafetyScore =
0.30 × ActivityLikelihoodScore
0.25 × LightingScore
0.20 × CrowdScore
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
  "segments": [
    {
        "coordinate": {
            "lat": 27.1751,
            "lng": 78.0421
        },
        "lighting_score": 65,
        "crowd_score": 72,
        "time_of_day_score": 60,
        "road_type_score": 80,
        "activity_likelihood_score": 61,
        "segment_safety_score": 66
    },
  ... ]
}
```

---

Future Improvements:

- Historical crime data integration
- Gemini based chat for in-depth safety explanations
- User preference tuning for commonly used routes 
- User reported safety scores for segments/routes
