import os
from functools import wraps
from typing import Callable, Optional
from datetime import datetime, timezone

import jwt
from flask import request, jsonify, g


def auth_required(f: Callable):
    @wraps(f)
    def wrapper(*args, **kwargs):
        auth = request.headers.get("Authorization", "")
        if not auth.startswith("Bearer "):
            return jsonify({"detail": "Missing or invalid Authorization header"}), 401
        token = auth.split(" ", 1)[1].strip()
        try:
            payload = jwt.decode(
                token,
                os.getenv("JWT_SECRET", "dev-secret-change-me"),
                algorithms=[os.getenv("JWT_ALGORITHM", "HS256")],
                options={"require": ["sub", "exp"], "verify_aud": False},
            )
            if payload.get("type") != "access":
                return jsonify({"detail": "Invalid token type"}), 401
            # Optional: check exp explicitly
            if int(payload.get("exp", 0)) <= int(datetime.now(timezone.utc).timestamp()):
                return jsonify({"detail": "Token expired"}), 401
            # Stash user id for downstream
            g.user_id = payload.get("sub")
            g.token_payload = payload
        except jwt.PyJWTError:
            return jsonify({"detail": "Invalid token"}), 401
        return f(*args, **kwargs)

    return wrapper
