from __future__ import annotations
from dataclasses import dataclass

from entities.user import User
from ..repositories.user_repository import UserRepository


@dataclass
class GetUserProfile:
    repo: UserRepository

    async def __call__(self, user_id: str) -> User:
        if not user_id:
            raise ValueError("user_id is required")
        user = await self.repo.get_user(user_id)
        if not user:
            raise ValueError("User not found")
        return user
