# FoodMind 🍕
### Point. Think. Know.

> An AI-powered iOS food scanning app that identifies your food, calculates every calorie, and places a **3D model of the dish floating on your table** using ARKit.

<br>

## 📱 Demo

[![FoodMind Demo](https://img.youtube.com/vi/-IEH7jZxJ8Q/maxresdefault.jpg)](https://youtube.com/shorts/-IEH7jZxJ8Q)

> Tap the thumbnail to watch the full demo ↑

<br>

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 **Live Scanning** | Point camera at food — CoreML classifies in real-time at 30fps |
| 🧠 **Deep Scan** | Full nutrition breakdown with calories, macros, ingredients and recipe |
| 🥩 **Ingredient Overlay** | Ingredient labels slide in over the food photo with positions from Gemini |
| 🌍 **AR Mode** | 3D food model appears on your table with floating ingredient labels |
| 📲 **Social Feed** | Share scans, like posts, explore what others are eating |
| 📊 **Stats Dashboard** | Weekly nutrition tracking with charts |
| 🔎 **Search** | Filter by dish, cuisine or trending tags with nutrition summaries |

<br>

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────┐
│                    iOS App (Swift)                   │
│                                                      │
│  AVFoundation → CoreML → Vision → WebSocket → ARKit  │
│       ↓            ↓        ↓                  ↓    │
│   Live Feed   Classify  Distance            3D Model │
└──────────────────────────┬──────────────────────────┘
                           │ WebSocket
┌──────────────────────────▼──────────────────────────┐
│                 Backend (FastAPI)                    │
│                                                      │
│  YOLOv8 ──┐                                         │
│            ├── Sensor Fusion → Final Result          │
│  Gemini ───┘                                         │
│                                                      │
│  PostgreSQL │ Cloudinary │ Sketchfab │ HuggingFace   │
└─────────────────────────────────────────────────────┘
```

<br>

## 📱 iOS Stack

| Technology | Usage |
|---|---|
| **Swift / SwiftUI** | Full UI layer |
| **CoreML + Create ML** | On-device food classification (Food101, 101 classes) |
| **Vision Framework** | Real-time distance detection & saliency |
| **AVFoundation** | Live 30fps camera pipeline |
| **ARKit + SceneKit** | 3D model placement + ingredient labels in real space |
| **LiDAR** | Depth assistance for surface detection |
| **WebSocket** | Real-time bidirectional communication |
| **Metal (MSL)** | Custom GPU compute shader for scan animation (iterated to SwiftUI overlay) |

<br>

## 🧠 AI Pipeline

```
Camera Frame
     ↓
CoreML (on-device, 30fps)
→ Food classification + confidence
     ↓
WebSocket → Backend
     ↓
┌────────────────┐    ┌─────────────────────────────┐
│    YOLOv8      │    │      Gemini 2.5 Flash        │
│ Food detection │    │ Nutrition + ingredient        │
│ Bounding box   │    │ positions + recipe           │
│ for AR anchor  │    │                              │
└───────┬────────┘    └──────────────┬───────────────┘
        │                            │
        └────────── Sensor Fusion ───┘
                         ↓
              Combined confidence score
              (same principle as autonomous vehicles)
```

<br>

## ⚙️ Backend Stack

| Technology | Usage |
|---|---|
| **FastAPI** | REST API + WebSocket server |
| **PostgreSQL (Neon)** | Users, scans, social posts |
| **Cloudinary** | Permanent image + 3D model storage |
| **Sketchfab API** | Dynamic 3D model search + download |
| **HuggingFace Spaces** | Deployment (Docker) |
| **JWT** | Authentication |
| **YOLOv8** | Food detection + bounding box |
| **Gemini 2.5 Flash** | Nutrition analysis + ingredient mapping |

<br>

## 🌍 AR Pipeline

```
YOLO bounding box (screen coords)
          ↓
ARKit raycast → world position on surface
          ↓
SCNScene loads .usdz from Cloudinary
          ↓
3D model placed at food position
          ↓
Ingredient labels orbit model
(Billboard constraint — always face camera)
          ↓
Float animation + pinch to zoom
```

<br>

## 🗄 Database Schema

```sql
users   → id, email, username, avatar_url
scans   → id, user_id, dish_name, calories, macros,
          ingredients (JSONB), recipe_steps (JSONB),
          image_url, confidence, validation_level
posts   → id, user_id, scan_id, caption, image_url,
          dish_name, calories, macros, likes_count
```

<br>

## 🚧 Currently Iterating

- **EfficientNet-B4** migration — replacing Food101 Image Classification for better accuracy across diverse and non-Western foods
- **Continuous Face Recognition (CFR)** — biometric lock so only the registered user can access their nutrition data
- **SegFormer** pixel-level ingredient segmentation — explored, evaluating better food-specific models

<br>

## 📁 Project Structure

```
FoodMind/
├── App/
│   └── FoodMindApp.swift
├── Screens/
│   ├── Feed/
│   ├── Camera/
│   ├── Result/
│   ├── Search/
│   ├── Stats/
│   └── Profile/
├── AR/
│   ├── FoodARView.swift
│   └── FoodARViewController.swift
├── Metal/
│   ├── FoodScanShader.metal
│   └── MetalProcessor.swift
├── Core/
│   ├── Camera/
│   ├── ML/
│   └── WebSocket/
└── Services/

foodmind-backend/
├── app/
│   ├── router/
│   ├── services/
│   │   ├── gemini_service.py
│   │   ├── yolo_service.py
│   │   ├── sketchfab_service.py
│   │   └── cloudinary_service.py
│   └── db/
├── Dockerfile
└── requirements.txt
```

<br>

## 🚀 Backend Setup

```bash
git clone https://github.com/AhmadDurrani579/foodmind
cd foodmind-backend

# Add environment variables
cp .env.example .env
# Fill in: GEMINI_API_KEY, SKETCHFAB_TOKEN,
#          CLOUDINARY_*, DATABASE_URL, JWT_SECRET

# Run locally
pip install -r requirements.txt
uvicorn app.main:app --reload --port 7860
```

<br>

## 📱 iOS Setup

```bash
git clone https://github.com/AhmadDurrani579/FoodMind
cd FoodMind

# Open in Xcode
open FoodMind.xcodeproj

# Update APIConfig.swift with your backend URL
# Build and run on real device (ARKit requires physical iPhone)
```

> ⚠️ ARKit, CoreML and LiDAR require a physical iPhone — simulator not supported

<br>

## 👤 About

**Ahmad Durrani** — Senior iOS Engineer with an MSc in Computer Vision, Robotics & ML

- 10+ years iOS development
- Contributor to **Google WebRTC** (C++) and **OpenCV**
- 8 live App Store apps

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://www.linkedin.com/in/ahmad-yar-98990690)
[![Email](https://img.shields.io/badge/Email-Contact-green)](mailto:ahmaddurranitrg@gmail.com)

<br>

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

3D models sourced from Sketchfab under Creative Commons Attribution licenses.
Model authors are credited in the app at time of display.

---

*Built with ❤️ and way too much coffee*
