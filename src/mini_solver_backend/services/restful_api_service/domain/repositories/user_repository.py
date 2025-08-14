from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Optional

from entities.user import User


class UserRepository(ABC):
    @abstractmethod
    async def get_user(self, user_id: str) -> User | None:
        raise NotImplementedError

    @abstractmethod
    async def get_user_by_email(self, email: str) -> User | None:
        raise NotImplementedError

    @abstractmethod
    async def create_user(self, name: str, email: str, password: str) -> User:
        """Creates a user and handles password hashing and persistence."""
        raise NotImplementedError

    @abstractmethod
    async def verify_password(self, password: str, password_hash: str) -> bool:
        raise NotImplementedError

    @abstractmethod
    async def issue_tokens(self, user: User) -> tuple[str, str]:
        """Return (access_token, refresh_token) for the given user."""
        raise NotImplementedError

    @abstractmethod
    async def verify_refresh_token(self, refresh_token: str) -> str | None:
        """Verify refresh token and return user_id (sub) if valid, else None."""
        raise NotImplementedError
