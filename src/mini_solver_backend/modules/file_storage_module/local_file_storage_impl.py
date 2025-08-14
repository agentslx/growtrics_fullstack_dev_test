import os
import asyncio
import shutil
from pathlib import Path
from typing import Optional

from .file_storage_module import FileStorageModule


class LocalFileStorageModule(FileStorageModule):
    """Local filesystem-backed storage implementation.

    Uses a base directory configured via the LOCAL_STORAGE_DIR environment variable.
    Remote paths map to files under this base directory.
    """

    def __init__(self, base_dir: Optional[str] = None):
        base = base_dir or os.getenv("LOCAL_STORAGE_DIR")
        if not base:
            raise ValueError(
                "LOCAL_STORAGE_DIR environment variable is required for LocalFileStorageModule"
            )
        self.base_dir = Path(base).expanduser().resolve()
        self.base_dir.mkdir(parents=True, exist_ok=True)

    def _to_abs(self, remote_path: str) -> Path:
        # Prevent path escape via ..
        rp = Path(remote_path.lstrip("/"))
        abs_path = (self.base_dir / rp).resolve()
        if self.base_dir not in abs_path.parents and self.base_dir != abs_path:
            raise ValueError("Remote path escapes base directory")
        return abs_path

    async def upload_file(self, local_path: str, dest_path: str, content_type: Optional[str] = None) -> str:
        def _inner():
            src = Path(local_path)
            dst = self._to_abs(dest_path)
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            return dst.as_uri()  # file:/// URL

        return await asyncio.to_thread(_inner)

    async def download_file(self, remote_path: str, local_path: str) -> None:
        def _inner():
            src = self._to_abs(remote_path)
            dst = Path(local_path).expanduser().resolve()
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)

        return await asyncio.to_thread(_inner)

    async def delete_file(self, remote_path: str) -> None:
        def _inner():
            p = self._to_abs(remote_path)
            try:
                p.unlink()
            except FileNotFoundError:
                pass

        return await asyncio.to_thread(_inner)

    async def get_download_url(self, remote_path: str, expires_in_seconds: int = 3600) -> str:
        def _inner():
            p = self._to_abs(remote_path)
            return p.as_uri()

        return await asyncio.to_thread(_inner)
