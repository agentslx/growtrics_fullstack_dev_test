

from typing import Any, Dict, List, Optional
from pydantic import BaseModel

class SolveResult(BaseModel):
    solution: Optional[str] = None
    final_result: Optional[str] = None
    error: Optional[str] = None

class SolveResponse(BaseModel):
    request_id: str
    status: str
    error: Optional[str] = None
    results: Optional[List[SolveResult]] = None

