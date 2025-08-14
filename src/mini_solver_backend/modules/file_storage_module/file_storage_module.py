from abc import ABC, abstractmethod
from typing import Optional


class FileStorageModule(ABC):
    """Abstract interface for a file storage module."""

    @abstractmethod
    async def upload_file(self, local_path: str, dest_path: str, content_type: Optional[str] = None) -> str:
        """Upload a file to storage. Returns a public URL or signed URL."""
        raise NotImplementedError

    @abstractmethod
    async def download_file(self, remote_path: str, local_path: str) -> None:
        """Download a file from storage to a local path."""
        raise NotImplementedError

    @abstractmethod
    async def delete_file(self, remote_path: str) -> None:
        """Delete a file from storage."""
        raise NotImplementedError

    @abstractmethod
    async def get_download_url(self, remote_path: str, expires_in_seconds: int = 3600) -> str:
        """Get a signed download URL for a file if supported. If not, return public URL."""
        raise NotImplementedError
