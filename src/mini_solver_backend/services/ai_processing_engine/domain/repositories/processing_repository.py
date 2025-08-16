

from abc import ABC, abstractmethod

from entities.solve_request import SolveResult


class ProcessingRepository(ABC):
    @abstractmethod
    async def download_image(self, remote_path: str) -> str:
        raise NotImplementedError

    @abstractmethod
    async def solve_problem_with_llm(self, prompt: str, image_local_path: str) -> list[SolveResult]:
        raise NotImplementedError

    @abstractmethod
    async def send_result(self, body: dict) -> None:
        raise NotImplementedError
