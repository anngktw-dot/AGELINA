from datetime import datetime, timezone
from typing import Dict, List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

app = FastAPI(title="FamilyGuard API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


class CheckIn(BaseModel):
    status: str = Field(min_length=1, max_length=80)
    location_label: str = Field(default="Not shared", max_length=120)
    battery_percent: int = Field(default=100, ge=0, le=100)


class UsageUpdate(BaseModel):
    screen_time_minutes: int = Field(ge=0, le=24 * 60)
    top_apps: List[str] = Field(default_factory=list, max_length=10)


children: Dict[int, dict] = {
    1: {
        "id": 1,
        "name": "Alex",
        "status": "All good",
        "location_label": "Home",
        "battery_percent": 86,
        "screen_time_minutes": 132,
        "top_apps": ["YouTube", "Maps", "Messages"],
        "last_check_in": datetime.now(timezone.utc).isoformat(),
    }
}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/children")
def list_children():
    return list(children.values())


@app.get("/children/{child_id}")
def get_child(child_id: int):
    child = children.get(child_id)
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")
    return child


@app.post("/children/{child_id}/check-in")
def create_check_in(child_id: int, payload: CheckIn):
    child = children.get(child_id)
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")

    child.update(
        status=payload.status,
        location_label=payload.location_label,
        battery_percent=payload.battery_percent,
        last_check_in=datetime.now(timezone.utc).isoformat(),
    )
    return child


@app.post("/children/{child_id}/usage")
def update_usage(child_id: int, payload: UsageUpdate):
    child = children.get(child_id)
    if not child:
        raise HTTPException(status_code=404, detail="Child not found")

    child.update(
        screen_time_minutes=payload.screen_time_minutes,
        top_apps=payload.top_apps,
    )
    return child
