from __future__ import annotations

from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):
    name: str
    email: EmailStr
    password: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: str
    name: str
    email: EmailStr
    is_verified: bool
    created_at: str
    updated_at: str


class AuthResponse(BaseModel):
    user: UserResponse
    access_token: str
    refresh_token: str


class RefreshRequest(BaseModel):
    refresh_token: str
