from __future__ import annotations

from flask import Blueprint, jsonify

router = Blueprint("health", __name__)


@router.get("/")
def health():
    return jsonify({"status": "ok"})
