

import os
from typing import Optional, Any, Dict

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status, Security
from fastapi.security import HTTPBearer
from kink import di

from ..middlewares.auth_middleware import require_auth

# Bearer security scheme so Swagger shows the Authorize button
bearer_scheme = HTTPBearer()
from ...domain.usecases.create_and_process_solve_request import CreateAndProcessSolveRequest
from ..schemas.solve import SolveResponse


router = APIRouter(
    prefix="/solve",
    tags=["solve"],
    dependencies=[Security(bearer_scheme), Depends(require_auth)],
)


@router.post("", summary="Submit a problem image to be solved", response_model=SolveResponse)
async def solve(
    image: UploadFile = File(..., description="Problem image file"),
    prompt: Optional[str] = Form(default=None),
    user_id: str = Depends(require_auth),
):
    usecase: CreateAndProcessSolveRequest = di[CreateAndProcessSolveRequest]
    try:
        result: Dict[str, Any] = await usecase(
            image_filename=image.filename or "image.jpg",
            image_bytes=await image.read(),
            content_type=image.content_type,
            prompt=prompt,
            user_id=user_id,
        )
        return result
    except TimeoutError as e:
        raise HTTPException(status_code=status.HTTP_504_GATEWAY_TIMEOUT, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Solve request failed")
