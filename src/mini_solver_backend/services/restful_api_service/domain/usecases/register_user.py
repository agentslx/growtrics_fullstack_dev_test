from __future__ import annotations

from dataclasses import dataclass

from entities.user import User
from ..repositories.user_repository import UserRepository


@dataclass
class RegisterUser:
    repo: UserRepository

    async def __call__(self, name: str, email: str, password: str) -> tuple[User, str, str]:
        print("Registering user...")
        if not name or not email or not password:
            raise ValueError("name, email, password are required")

        # Check email uniqueness
        existing = await self.repo.get_user_by_email(email)
        print("User exist", existing)
        if existing:
            raise ValueError("Email already registered")

        print("Creating user...")
        user = await self.repo.create_user(name=name, email=email, password=password)
        print(f"User created: {user}")
        access, refresh = await self.repo.issue_tokens(user)
        return user, access, refresh
