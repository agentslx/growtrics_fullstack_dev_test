from __future__ import annotations
from fastapi import APIRouter, Depends, Header, HTTPException, status
from kink import di
import os
from datetime import datetime, timezone
import jwt

from entities.user import User
from ...domain.usecases.get_user_profile import GetUserProfile
from ..schemas.auth import UserResponse

router = APIRouter(prefix="/users", tags=["users"])


async def get_current_user_id(authorization: str = Header(default="")) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing or invalid Authorization header")
    token = authorization.split(" ", 1)[1].strip()
    try:
        payload = jwt.decode(
            token,
            os.getenv("JWT_SECRET", "dev-secret-change-me"),
            algorithms=[os.getenv("JWT_ALGORITHM", "HS256")],
            options={"require": ["sub", "exp"], "verify_aud": False},
        )
        if payload.get("type") != "access":
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token type")
        if int(payload.get("exp", 0)) <= int(datetime.now(timezone.utc).timestamp()):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expired")
        return payload.get("sub")
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")


@router.get("/me", response_model=UserResponse)
async def get_me(user_id: str = Depends(get_current_user_id)):
    usecase: GetUserProfile = di[GetUserProfile]
    try:
        user: User = await usecase(user_id)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND if str(e) == "User not found" else status.HTTP_400_BAD_REQUEST, detail=str(e))

    return UserResponse(
        id=user.id,
        name=user.name,
        email=user.email,
        is_verified=user.is_verified,
        created_at=user.created_at.isoformat(),
        updated_at=user.updated_at.isoformat(),
    )
