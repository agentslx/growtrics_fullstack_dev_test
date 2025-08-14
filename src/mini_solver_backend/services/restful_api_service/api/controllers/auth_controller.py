from __future__ import annotations

from fastapi import APIRouter, HTTPException, status
from kink import di

from entities.user import User
from ...domain.usecases.register_user import RegisterUser
from ...domain.usecases.login_user import LoginUser
from ...domain.usecases.refresh_tokens import RefreshTokens
from ..schemas.auth import RegisterRequest, LoginRequest, UserResponse, AuthResponse, RefreshRequest

router = APIRouter(prefix="/auth", tags=["auth"])


def _to_user_response(user: User) -> UserResponse:
    return UserResponse(
        id=user.id,
        name=user.name,
        email=user.email,
        is_verified=user.is_verified,
        created_at=user.created_at.isoformat(),
        updated_at=user.updated_at.isoformat(),
    )


@router.post("/register", response_model=AuthResponse)
async def register(req: RegisterRequest):
    usecase: RegisterUser = di[RegisterUser]
    try:
        user, access, refresh = await usecase(req.name, str(req.email), req.password)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    return AuthResponse(user=_to_user_response(user), access_token=access, refresh_token=refresh)


@router.post("/login", response_model=AuthResponse)
async def login(req: LoginRequest):
    usecase: LoginUser = di[LoginUser]
    try:
        user, access, refresh = await usecase(str(req.email), req.password)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))
    return AuthResponse(user=_to_user_response(user), access_token=access, refresh_token=refresh)


@router.post("/refresh", response_model=AuthResponse)
async def refresh(req: RefreshRequest):
    usecase: RefreshTokens = di[RefreshTokens]
    try:
        user, access, refresh = await usecase(req.refresh_token)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))
    return AuthResponse(user=_to_user_response(user), access_token=access, refresh_token=refresh)
