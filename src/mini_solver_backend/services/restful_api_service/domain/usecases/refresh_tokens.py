
from dataclasses import dataclass

from entities.user import User
from ..repositories.user_repository import UserRepository


@dataclass
class RefreshTokens:
    repo: UserRepository

    async def __call__(self, refresh_token: str) -> tuple[User, str, str]:
        if not refresh_token:
            raise ValueError("refresh_token is required")

        user_id = await self.repo.verify_refresh_token(refresh_token)
        if not user_id:
            raise ValueError("Invalid token")

        user = await self.repo.get_user(user_id)
        if not user:
            raise ValueError("User not found")

        access, refresh = await self.repo.issue_tokens(user)
        return user, access, refresh
