

from abc import ABC, abstractmethod
from typing import Any, Dict, Optional


class SolveRepository(ABC):
    @abstractmethod
    async def create_solve_request(self, request_id: str, user_id: Optional[str], prompt: Optional[str]) -> None:
        raise NotImplementedError

    @abstractmethod
    async def upload_image(self, request_id: str, filename: str, content_type: Optional[str], data: bytes) -> str:
        """Uploads image bytes and returns a remote storage path suitable for engine download."""
        raise NotImplementedError

    @abstractmethod
    async def send_request(self, payload: Dict[str, Any]) -> None:
        raise NotImplementedError

    @abstractmethod
    async def wait_for_result(self, request_id: str, timeout_sec: int = 60) -> Dict[str, Any]:
        """Wait for a message on reply_queue that matches request_id and return its payload."""
        raise NotImplementedError

    @abstractmethod
    async def update_solve_request(self, request_id: str, fields: Dict[str, Any]) -> None:
        raise NotImplementedError
