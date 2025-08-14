from __future__ import annotations

import uuid
from dataclasses import dataclass
from typing import Optional, Dict, Any

from ...domain.repositories.solve_repository import SolveRepository


@dataclass
class CreateAndProcessSolveRequest:
    repo: SolveRepository

    async def __call__(
        self,
        image_filename: str,
        image_bytes: bytes,
        content_type: Optional[str],
        prompt: Optional[str],
        user_id: Optional[str],
        request_queue: str,
        reply_queue: str,
        timeout_sec: int = 60,
    ) -> Dict[str, Any]:
        # 1) Create DB record
        request_id = str(uuid.uuid4())
        await self.repo.create_solve_request(request_id, user_id, prompt)

        # 2) Upload image
        remote_path = await self.repo.upload_image(request_id, image_filename, content_type, image_bytes)

        # 3) Trigger processing via MQ (match engine contract in test.py)
        payload = {
            "id": request_id,
            "image_path": remote_path,
            "prompt": prompt,
            "user_id": user_id,
            "reply_queue": reply_queue,
        }
        await self.repo.send_request(request_queue, payload, reply_queue=reply_queue)

        # 4) Wait for result
        try:
            result = await self.repo.wait_for_result(reply_queue, request_id, timeout_sec=timeout_sec)
        except Exception as e:
            # Mark as error and re-raise
            await self.repo.update_solve_request(request_id, {"status": "error", "error": str(e)})
            if type(e).__name__ == "TimeoutError":
                raise TimeoutError(f"Timed out waiting for result for request {request_id}")
            raise

        # 5) Update DB and return
        status = "done" if result.get("error") in (None, "") else "error"
        await self.repo.update_solve_request(request_id, {"status": status, "result": result})

        return {"request_id": request_id, "status": status, "result": result}
