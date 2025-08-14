from __future__ import annotations

from typing import Any, Dict
from pydantic import BaseModel


class SolveResponse(BaseModel):
    request_id: str
    status: str
    result: Dict[str, Any]
