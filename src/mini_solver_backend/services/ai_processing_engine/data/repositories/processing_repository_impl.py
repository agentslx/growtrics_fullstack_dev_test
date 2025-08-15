import os
import tempfile
from typing import Optional

from entities.solve_request import SolveResult
from modules import FileStorageModule, LLMModule, MessageQueueModule
from ...domain.repositories.processing_repository import ProcessingRepository


class ProcessingRepositoryImpl(ProcessingRepository):
    def __init__(self, storage: FileStorageModule, llm: LLMModule, mq: MessageQueueModule):
        self.storage = storage
        self.llm = llm
        self.mq = mq

        self.reply_queue = os.getenv("REPLY_QUEUE", "solve_results")

    async def download_image(self, remote_path: str) -> str:
        # Download to a temp file, preserve extension if any
        _, ext = os.path.splitext(remote_path)
        fd, tmp_path = tempfile.mkstemp(suffix=ext or ".img")
        os.close(fd)
        await self.storage.download_file(remote_path, tmp_path)
        return tmp_path

    async def solve_problem_with_llm(self, prompt: str, image_local_path: str) -> list[SolveResult]:
        result = await self.llm.process(prompt=prompt, image_path=image_local_path, output_schema=list[SolveResult])
        return result

    async def send_result(self, body: dict) -> None:
        await self.mq.publish(self.reply_queue, body)
