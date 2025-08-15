

from dataclasses import dataclass

from entities.user import User
from ..repositories.user_repository import UserRepository


@dataclass
class LoginUser:
    repo: UserRepository

    async def __call__(self, email: str, password: str) -> tuple[User, str, str]:
        if not email or not password:
            raise ValueError("email and password are required")

        user = await self.repo.get_user_by_email(email)
        if not user:
            raise ValueError("Invalid credentials")

        if not await self.repo.verify_password(password, user.password_hash):
            raise ValueError("Invalid credentials")

        access, refresh = await self.repo.issue_tokens(user)
        return user, access, refresh
