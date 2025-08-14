from __future__ import annotations

import os
import uuid
import asyncio
from datetime import datetime, timezone
from typing import Any, Dict, Optional

from modules import DocumentDBModule, FileStorageModule, MessageQueueModule
from ...domain.repositories.solve_repository import SolveRepository


class SolveRepositoryImpl(SolveRepository):
    def __init__(self, db: DocumentDBModule, storage: FileStorageModule, mq: MessageQueueModule):
        self.db = db
        self.storage = storage
        self.mq = mq

    async def create_solve_request(self, request_id: str, user_id: Optional[str], prompt: Optional[str]) -> None:
        now = datetime.now(timezone.utc).isoformat()
        await self.db.create_document(
            "solve_requests",
            {
                "id": request_id,
                "user_id": user_id,
                "prompt": prompt,
                "status": "pending",
                "created_at": now,
                "updated_at": now,
            },
            doc_id=request_id,
        )

    async def upload_image(self, request_id: str, filename: str, content_type: Optional[str], data: bytes) -> str:
        remote_path = f"solve_requests/{request_id}/{filename}"
        # Save to storage from bytes via a temp file to reuse current interface
        import tempfile

        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            tmp.write(data)
            tmp.flush()
            local_path = tmp.name
        try:
            await self.storage.upload_file(local_path, remote_path, content_type=content_type)
        finally:
            try:
                os.remove(local_path)
            except Exception:
                pass
        return remote_path

    async def send_request(self, queue: str, payload: Dict[str, Any], reply_queue: Optional[str] = None) -> None:
        await self.mq.connect()
        # Ensure reply queue exists before sending request to avoid race conditions
        if reply_queue:
            await self.mq.declare_queue(reply_queue)
        await self.mq.declare_queue(queue)
        await self.mq.publish(queue, payload)
        await self.mq.close()

    async def wait_for_result(self, reply_queue: str, request_id: str, timeout_sec: int = 60) -> Dict[str, Any]:
        await self.mq.connect()
        await self.mq.declare_queue(reply_queue)

        loop = asyncio.get_running_loop()
        fut: asyncio.Future = loop.create_future()

        async def handler(body: bytes, headers: Dict[str, Any]):
            try:
                import json

                msg = json.loads(body.decode("utf-8"))
                print("Received message:", msg)
                if msg.get("request_id") == request_id:
                    if not fut.done():
                        fut.set_result(msg)
            except Exception as e:
                if not fut.done():
                    fut.set_exception(e)

        consume_task = asyncio.create_task(self.mq.consume(reply_queue, handler, prefetch_count=1, auto_ack=True))
        try:
            result = await asyncio.wait_for(fut, timeout=timeout_sec)
            return result
        finally:
            consume_task.cancel()
            try:
                await self.mq.close()
            except Exception:
                pass

    async def update_solve_request(self, request_id: str, fields: Dict[str, Any]) -> None:
        fields["updated_at"] = datetime.now(timezone.utc).isoformat()
        await self.db.update_document("solve_requests", request_id, fields, merge=True)
