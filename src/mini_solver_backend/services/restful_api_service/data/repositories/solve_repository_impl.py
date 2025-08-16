

import os
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

        self.request_queue = os.getenv("REQUEST_QUEUE", "solve_requests")
        self.reply_queue = os.getenv("REPLY_QUEUE", "solve_results")
        self.timeout_sec = int(os.getenv("SOLVE_TIMEOUT_SEC", "60"))

        # Single, shared listener state for reply messages
        self._listener_started = False
        self._listener_task = None  # background task for consumer
        self._listener_lock = asyncio.Lock()
        # Map of request_id -> result payload (set by listener). None means pending.
        self._pending_results = {}
        # Map of request_id -> asyncio.Event to notify waiters when result arrives
        self._result_events = {}


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

    async def send_request(self, payload: Dict[str, Any]) -> None:
        # Ensure the background listener is running and reply queue declared
        await self._ensure_listener()
        # Declare request queue (idempotent) and publish without closing the MQ,
        # so the shared listener remains active.
        await self.mq.declare_queue(self.request_queue)
        await self.mq.publish(self.request_queue, payload)

    async def wait_for_result(self, request_id: str, timeout_sec: int = 60) -> Dict[str, Any]:
        # Ensure the background listener is running
        await self._ensure_listener()

        # Register this request_id as pending and wait until the listener fills it
        async with self._listener_lock:
            if request_id not in self._pending_results:
                self._pending_results[request_id] = None
            event = self._result_events.get(request_id)
            if event is None:
                event = asyncio.Event()
                self._result_events[request_id] = event

        # Quick check in case result already arrived before we started waiting
        if self._pending_results.get(request_id) is not None:
            result = self._pending_results.pop(request_id)  # type: ignore[assignment]
            self._result_events.pop(request_id, None)
            return result  # type: ignore[return-value]

        # Wait in a loop until the result is filled or timeout
        deadline = asyncio.get_running_loop().time() + timeout_sec
        while True:
            remaining = deadline - asyncio.get_running_loop().time()
            if remaining <= 0:
                # Cleanup on timeout
                async with self._listener_lock:
                    self._pending_results.pop(request_id, None)
                    self._result_events.pop(request_id, None)
                raise asyncio.TimeoutError(f"Timed out waiting for result for request_id={request_id}")

            try:
                await asyncio.wait_for(event.wait(), timeout=remaining)
            except asyncio.TimeoutError:
                # Loop will check remaining and raise
                pass

            # Check if listener filled the result
            result = self._pending_results.get(request_id)
            if result is not None:
                async with self._listener_lock:
                    # Remove and return the result
                    self._pending_results.pop(request_id, None)
                    self._result_events.pop(request_id, None)
                return result

    async def update_solve_request(self, request_id: str, fields: Dict[str, Any]) -> None:
        fields["updated_at"] = datetime.now(timezone.utc).isoformat()
        await self.db.update_document("solve_requests", request_id, fields, merge=True)

    # Internal: start a single, shared listener for reply messages
    async def _ensure_listener(self) -> None:
        if self._listener_started:
            return
        async with self._listener_lock:
            if self._listener_started:
                return

            await self.mq.connect()
            await self.mq.declare_queue(self.reply_queue)

            async def handler(body: bytes, headers: Dict[str, Any]):
                import json
                try:
                    msg = json.loads(body.decode("utf-8"))
                    req_id = msg.get("request_id")
                    if not req_id:
                        return
                    # Store the result (even if no waiter yet) and notify waiters if any
                    async with self._listener_lock:
                        self._pending_results[req_id] = msg
                        evt = self._result_events.get(req_id)
                        if evt is not None and not evt.is_set():
                            evt.set()
                except Exception:
                    # Swallow errors to keep listener alive
                    return

            # Start the background consumer task (auto ack; small prefetch)
            self._listener_task = asyncio.create_task(
                self.mq.consume(self.reply_queue, handler, prefetch_count=10, auto_ack=True)
            )
            self._listener_started = True
