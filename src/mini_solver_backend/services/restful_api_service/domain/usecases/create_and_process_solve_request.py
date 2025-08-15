

import uuid
from dataclasses import dataclass
import os
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
    ) -> Dict[str, Any]:
        # 1) Create DB record
        request_id = str(uuid.uuid4())
        await self.repo.create_solve_request(request_id, user_id, prompt)

        # 2) Upload image
        remote_path = await self.repo.upload_image(request_id, image_filename, content_type, image_bytes)

        # 3) Trigger processing via MQ (engine reads queues from env)
        payload = {
            "id": request_id,
            "image_path": remote_path,
            "prompt": prompt,
            "user_id": user_id,
        }
        await self.repo.send_request(payload)

        # 4) Wait for result
        try:
            result = await self.repo.wait_for_result(request_id)
            print("Result:", result)
        except Exception as e:
            # Mark as error and re-raise
            await self.repo.update_solve_request(request_id, {"status": "error", "error": str(e)})
            if type(e).__name__ == "TimeoutError":
                raise TimeoutError(f"Timed out waiting for result for request {request_id}")
            raise

        # 5) Update DB and return
        # Engine publishes either {'request_id', 'results': [...]} or includes 'error'
        results = result.get("results") if isinstance(result, dict) else None
        error = result.get("error") if isinstance(result, dict) else None
        status = "done" if error in (None, "") else "error"
        await self.repo.update_solve_request(
            request_id,
            {
                "status": status,
                "results": results,
                "error": error,
            },
        )

        return {
            "request_id": request_id,
            "status": status,
            "results": results,
            "error": error
        }
