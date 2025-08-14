from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, status, Security
from fastapi.security import HTTPBearer
from kink import di

from entities.user import User
from ...domain.usecases.get_user_profile import GetUserProfile
from ..schemas.auth import UserResponse
from ..middlewares.auth_middleware import require_auth

# Bearer security scheme so Swagger shows the Authorize button for protected routes
bearer_scheme = HTTPBearer()

router = APIRouter(
    prefix="/users",
    tags=["users"],
    dependencies=[Security(bearer_scheme), Depends(require_auth)],
)


@router.get("/me", response_model=UserResponse)
async def get_me(user_id: str = Depends(require_auth)):
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
