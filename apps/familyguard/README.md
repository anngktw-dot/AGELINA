# FamilyGuard

**Family safety / parental-control MVP** with separate parent and child experiences plus a small backend service.

This repository contains a portfolio reconstruction of the personal FamilyGuard project. The demo focuses on transparent, consent-based family safety features rather than hidden device monitoring.

## What the app is for

FamilyGuard is designed for a parent and child to use together:

- the **child side** can send a check-in and share current status/location intentionally;
- the **parent side** can see the latest check-in, battery/device status, screen-time summary and app-usage summary;
- the **backend** keeps the shared family state and exposes a small REST API.

## Stack

- Python
- FastAPI
- Pydantic
- HTML / CSS / JavaScript

## Project structure

```text
familyguard/
├── backend/
│   ├── main.py
│   └── requirements.txt
└── web/
    ├── index.html
    ├── child.html
    ├── app.js
    └── styles.css
```

## Run locally

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # macOS/Linux
# .venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn main:app --reload
```

Then open `web/index.html` for the parent dashboard or `web/child.html` for the child check-in screen.

The API runs on `http://127.0.0.1:8000`.

## Demo API

- `GET /children`
- `GET /children/{child_id}`
- `POST /children/{child_id}/check-in`
- `POST /children/{child_id}/usage`

## Portfolio note

This version is intentionally a safe demo: it does **not** silently capture screenshots, browser history, messages, microphone data, or precise location. Any shared status in the demo is entered or submitted explicitly by the child side.
