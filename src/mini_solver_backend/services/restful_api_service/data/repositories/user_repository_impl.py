
import os
import asyncio
import bcrypt
import jwt

from datetime import datetime, timedelta, timezone
from entities.user import User
from ..datasources.user_document_db_datasource import UserDocumentDBDataSource
from ...domain.repositories.user_repository import UserRepository


class UserRepositoryImpl(UserRepository):
    def __init__(self, ds: UserDocumentDBDataSource):
        self.ds = ds

        self.jwt_secret = os.getenv("JWT_SECRET", "dev-secret-change-me")
        self.jwt_algorithm = os.getenv("JWT_ALGORITHM", "HS256")
        self.access_token_ttl_min = int(os.getenv("ACCESS_TOKEN_TTL_MIN", "60"))
        self.refresh_token_ttl_days = int(os.getenv("REFRESH_TOKEN_TTL_DAYS", "7"))

    async def _hash_password(self, password: str) -> str:
        def _inner():
            return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

        return await asyncio.to_thread(_inner)

    async def verify_password(self, password: str, password_hash: str) -> bool:
        def _inner():
            try:
                return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))
            except Exception:
                return False

        return await asyncio.to_thread(_inner)

    async def create_user(self, name: str, email: str, password: str) -> User:
        now = datetime.utcnow()
        password_hash = await self._hash_password(password)
        user_dict = {
            "name": name.strip(),
            "email": email.lower().strip(),
            "password_hash": password_hash,
            "created_at": now.isoformat(),
            "updated_at": now.isoformat(),
            "is_verified": False,
        }
        user_id = await self.ds.create(user_dict)
        return User(id=user_id, **{**user_dict, "created_at": now, "updated_at": now})

    async def get_user(self, user_id: str) -> User:
        doc = await self.ds.get_by_id(user_id)
        if not doc:
            return None
        return User(
            id=doc["id"],
            name=doc.get("name", ""),
            email=doc.get("email", ""),
            password_hash=doc.get("password_hash", ""),
            created_at=_parse_dt(doc.get("created_at")),
            updated_at=_parse_dt(doc.get("updated_at")),
            is_verified=bool(doc.get("is_verified", False)),
        )

    async def get_user_by_email(self, email: str) -> User:
        doc = await self.ds.get_by_email(email.lower().strip())
        if not doc:
            return None
        return User(
            id=doc["id"],
            name=doc.get("name", ""),
            email=doc.get("email", ""),
            password_hash=doc.get("password_hash", ""),
            created_at=_parse_dt(doc.get("created_at")),
            updated_at=_parse_dt(doc.get("updated_at")),
            is_verified=bool(doc.get("is_verified", False)),
        )

    async def issue_tokens(self, user: User) -> tuple[str, str]:
        

        now = datetime.now(timezone.utc)
        access_payload = {
            "sub": user.id,
            "email": str(user.email),
            "type": "access",
            "iat": int(now.timestamp()),
            "exp": int((now + timedelta(minutes=self.access_token_ttl_min)).timestamp()),
        }
        refresh_payload = {
            "sub": user.id,
            "type": "refresh",
            "iat": int(now.timestamp()),
            "exp": int((now + timedelta(days=self.refresh_token_ttl_days)).timestamp()),
        }
        access = jwt.encode(access_payload, self.jwt_secret, algorithm=self.jwt_algorithm)
        refresh = jwt.encode(refresh_payload, self.jwt_secret, algorithm=self.jwt_algorithm)
        return access, refresh

    async def verify_refresh_token(self, refresh_token: str) -> str:
        try:
            payload = jwt.decode(
                refresh_token,
                self.jwt_secret,
                algorithms=[self.jwt_algorithm],
                options={"require": ["sub", "exp"], "verify_aud": False},
            )
            if payload.get("type") != "refresh":
                return None
            return payload.get("sub")
        except jwt.PyJWTError:
            return None


def _parse_dt(val):
    if isinstance(val, datetime):
        return val
    try:
        return datetime.fromisoformat(val)
    except Exception:
        return datetime.utcnow()
