from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Optional

from entities.solve_request import SolveResult
from modules import FileStorageModule, LLMModule, MessageQueueModule


class ProcessingRepository(ABC):
    """Repository interface used by the use case. Implementations delegate to modules."""

    @abstractmethod
    async def download_image(self, remote_path: str) -> str:
        """Download an image and return the local file path."""
        raise NotImplementedError

    @abstractmethod
    async def solve_problem_with_llm(self, prompt: str, image_local_path: str) -> list[SolveResult]:
        raise NotImplementedError

    @abstractmethod
    async def send_result(self, queue: str, body: dict) -> None:
        raise NotImplementedError
