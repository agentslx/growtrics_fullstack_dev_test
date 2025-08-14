from __future__ import annotations

from flask import Blueprint, request, jsonify
from kink import di

from entities.user import User
from ...domain.usecases.register_user import RegisterUser
from ...domain.usecases.login_user import LoginUser
from ...domain.usecases.refresh_tokens import RefreshTokens
from ..schemas.auth import RegisterRequest, LoginRequest, UserResponse, AuthResponse, RefreshRequest

router = Blueprint("auth", __name__, url_prefix="/auth")


def _to_user_response(user: User) -> UserResponse:
    return UserResponse(
        id=user.id,
        name=user.name,
        email=user.email,
        is_verified=user.is_verified,
        created_at=user.created_at.isoformat(),
        updated_at=user.updated_at.isoformat(),
    )


@router.post("/register")
async def register():
    usecase: RegisterUser = di[RegisterUser]
    try:
        data = request.get_json(force=True, silent=False) or {}
        req = RegisterRequest(**data)
        user, access, refresh = await usecase(req.name, str(req.email), req.password)
    except ValueError as e:
        return jsonify({"detail": str(e)}), 400
    except Exception:
        return jsonify({"detail": "Bad request"}), 400

    resp = AuthResponse(user=_to_user_response(user), access_token=access, refresh_token=refresh)
    return jsonify(resp.model_dump())


@router.post("/login")
async def login():
    usecase: LoginUser = di[LoginUser]
    try:
        data = request.get_json(force=True, silent=False) or {}
        req = LoginRequest(**data)
        user, access, refresh = await usecase(str(req.email), req.password)
    except ValueError as e:
        return jsonify({"detail": str(e)}), 401
    except Exception:
        return jsonify({"detail": "Bad request"}), 400

    resp = AuthResponse(user=_to_user_response(user), access_token=access, refresh_token=refresh)
    return jsonify(resp.model_dump())


@router.post("/refresh")
async def refresh():
    usecase: RefreshTokens = di[RefreshTokens]
    try:
        data = request.get_json(force=True, silent=False) or {}
        req = RefreshRequest(**data)
        user, access, refresh = await usecase(req.refresh_token)
    except ValueError as e:
        return jsonify({"detail": str(e)}), 401
    except Exception:
        return jsonify({"detail": "Bad request"}), 400

    resp = AuthResponse(user=_to_user_response(user), access_token=access, refresh_token=refresh)
    return jsonify(resp.model_dump())
