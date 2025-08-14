from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr


class User(BaseModel):
    id: str
    name: str
    email: EmailStr
    password_hash: str
    created_at: datetime
    updated_at: datetime
    is_verified: bool = False

    def public_dict(self) -> dict:
        return {
            "id": self.id,
            "name": self.name,
            "email": str(self.email),
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
            "is_verified": self.is_verified,
        }
