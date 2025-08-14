import os
import time
import asyncio
from typing import Optional

from google.cloud import storage
from google.oauth2 import service_account

from .file_storage_module import FileStorageModule


class FirebaseStorageModule(FileStorageModule):
    """Google Cloud Storage backed Firebase Storage implementation."""

    def __init__(self, bucket_name: Optional[str] = None):
        credentials = None
        svc_file = os.getenv("FIREBASE_SERVICE_ACCOUNT_FILE")
        if svc_file and os.path.exists(svc_file):
            credentials = service_account.Credentials.from_service_account_file(svc_file)
        self.client = storage.Client(credentials=credentials)
        self.bucket_name = bucket_name or os.getenv("FIREBASE_STORAGE_BUCKET")
        if not self.bucket_name:
            raise ValueError("FIREBASE_STORAGE_BUCKET env var is required for FirebaseStorageModule")
        self.bucket = self.client.bucket(self.bucket_name)

    async def upload_file(self, local_path: str, dest_path: str, content_type: Optional[str] = None) -> str:
        def _inner():
            blob = self.bucket.blob(dest_path)
            blob.upload_from_filename(local_path, content_type=content_type)
            # Try to make public if bucket is public, else return signed url
            try:
                blob.make_public()
                return blob.public_url
            except Exception:
                # fallback to signed url
                return blob.generate_signed_url(expiration=3600)

        return await asyncio.to_thread(_inner)

    async def download_file(self, remote_path: str, local_path: str) -> None:
        def _inner():
            blob = self.bucket.blob(remote_path)
            blob.download_to_filename(local_path)

        return await asyncio.to_thread(_inner)

    async def delete_file(self, remote_path: str) -> None:
        def _inner():
            blob = self.bucket.blob(remote_path)
            blob.delete()

        return await asyncio.to_thread(_inner)

    async def get_download_url(self, remote_path: str, expires_in_seconds: int = 3600) -> str:
        def _inner():
            blob = self.bucket.blob(remote_path)
            try:
                # If already public
                return blob.public_url
            except Exception:
                pass
            return blob.generate_signed_url(expiration=expires_in_seconds)

        return await asyncio.to_thread(_inner)
