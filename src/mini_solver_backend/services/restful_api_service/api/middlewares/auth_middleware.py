from __future__ import annotations

import os
from datetime import datetime, timezone
from typing import Optional

import jwt
from fastapi import Request, HTTPException, status, Depends
from starlette.middleware.base import BaseHTTPMiddleware


class AuthMiddleware(BaseHTTPMiddleware):
    """
    FastAPI/Starlette middleware that:
    - Parses the Authorization: Bearer token if present.
    - Verifies JWT signature, type, and expiration.
    - Injects `request.state.user_id` and `request.state.token_payload` if valid.
    - Does NOT enforce authentication globally (public routes still work).

    Use the `require_user_id` dependency below on routes that must be authenticated.
    """

    async def dispatch(self, request: Request, call_next):
        auth = request.headers.get("Authorization", "")
        request.state.user_id = None
        request.state.token_payload = None

        if auth.startswith("Bearer "):
            token = auth.split(" ", 1)[1].strip()
            try:
                payload = jwt.decode(
                    token,
                    os.getenv("JWT_SECRET", "dev-secret-change-me"),
                    algorithms=[os.getenv("JWT_ALGORITHM", "HS256")],
                    options={"require": ["sub", "exp"], "verify_aud": False},
                )
                if payload.get("type") != "access":
                    # Invalid type, treat as unauthenticated but don't block public routes
                    return await call_next(request)
                if int(payload.get("exp", 0)) <= int(datetime.now(timezone.utc).timestamp()):
                    # Expired, treat as unauthenticated
                    return await call_next(request)
                request.state.user_id = payload.get("sub")
                request.state.token_payload = payload
            except jwt.PyJWTError:
                # Invalid token, proceed as unauthenticated
                pass

        response = await call_next(request)
        return response


async def require_auth(request: Request) -> str:
    """Dependency to enforce authentication on specific endpoints.

    Returns the current user id from request.state if available; otherwise raises 401.
    """
    user_id: Optional[str] = getattr(request.state, "user_id", None)
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing or invalid Authorization header")
    return user_id

# Backwards-compatible alias if anything still imports the old name
require_user_id = require_auth
