from typing import Optional, Dict, Any
from pydantic import BaseModel


class SolveRequest(BaseModel):
    id: str
    image_path: str
    prompt: Optional[str] = None
    user_id: Optional[str] = None
    reply_queue: Optional[str] = "solve_results"


class SolveResult(BaseModel):
    solution: str = None
    final_result: str = None
    error: str = None