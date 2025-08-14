from __future__ import annotations

from dataclasses import dataclass
import traceback

from entities.solve_request import SolveRequest, SolveResult
from ..repositories.processing_repository import ProcessingRepository


@dataclass
class ProcessRequest:
    repo: ProcessingRepository

    async def __call__(self, req: SolveRequest) -> SolveResult:
        try:
            local_path = await self.repo.download_image(req.image_path)
            print(f"Downloaded image to: {local_path}")

            prompt = """Analyze the math problems in the image. Provide a detailed, step-by-step solution. Return the output ONLY as a JSON object with keys:
1. "solution": A string containing the step-by-step explanation. Use LaTeX for equations. DO NOT include the final answer in the solution explanation.
2. "final_result": A string containing only the final answer.
3. "error": If there is an error, return empty solution and final_result, and include the error message in the "error" key.

The solution should be detailed and comprehensive so that the user can learn from the solution and calculate the final result themselves if they want to.
DO NOT include the final answer in the solution explanation, calculated result should be in the "final_result" key only.
There can be multiple problems to solve in the image, so return a list of solutions.

If image is invalid, inappropriate, or the problem cannot be solved, return an error message in the "error" key.
"""
            results = await self.repo.solve_problem_with_llm(prompt, local_path)

            print("LLM results:", results)

            await self.repo.send_result(req.reply_queue, {
                'request_id': req.id,
                'results': [r.model_dump() for r in results]
            })
            return results
        except Exception as e:
            print("Error processing request:", e, traceback.format_exc())
            result = SolveResult(request_id=req.id, success=False, error=str(e), metadata=req.metadata)
            await self.repo.send_result(req.reply_queue, [result.model_dump()])
            return result
