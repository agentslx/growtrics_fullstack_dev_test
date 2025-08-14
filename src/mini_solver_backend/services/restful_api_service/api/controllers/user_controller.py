from __future__ import annotations
from flask import Blueprint, jsonify, g
from kink import di

from entities.user import User
from ...domain.usecases.get_user_profile import GetUserProfile
from ..schemas.auth import UserResponse
from ..middlewares import auth_required

router = Blueprint("users", __name__, url_prefix="/users")


@router.get("/me")
@auth_required
def get_me():
    usecase: GetUserProfile = di[GetUserProfile]
    user_id = getattr(g, "user_id", None)
    if not user_id:
        return jsonify({"detail": "Unauthorized"}), 401

    # The repo is async; resolve synchronously for Flask
    async def _get():
        return await usecase(user_id)

    from asyncio import run as arun

    try:
        user: User = arun(_get())
    except ValueError as e:
        status = 404 if str(e) == "User not found" else 400
        return jsonify({"detail": str(e)}), status

    resp = UserResponse(
        id=user.id,
        name=user.name,
        email=user.email,
        is_verified=user.is_verified,
        created_at=user.created_at.isoformat(),
        updated_at=user.updated_at.isoformat(),
    )
    return jsonify(resp.model_dump())
