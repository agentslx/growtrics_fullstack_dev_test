from pydantic import BaseModel
from modules.llm_module import GeminiLLMModule

from dotenv import load_dotenv

load_dotenv()

class GeminiResponseSchema(BaseModel):
    solution: str
    final_result: str
    error: str = None

async def main():
    # Example usage of the GeminiLLMModule
    gemini_module = GeminiLLMModule(model='gemini-2.5-flash')
    prompt = """
    Analyze the math problem in the image.
    Provide a detailed, step-by-step solution.
    Return the output ONLY as a JSON object with two keys:
    1. "solution": A string containing the step-by-step explanation. Use LaTeX for equations. DO NOT include the final answer in the solution explanation.
    2. "final_result": A string containing only the final answer.
    3. "error": If there is an error, return empty solution and final_result, and include the error message in the "error" key.

    The solution should be detailed and comprehensive so that the user can learn from the solution and calculate the final result themselves if they want to.
    DO NOT include the final answer in the solution explanation, calculated result should be in the "final_result" key only.
    There can be multiple problems to solve in the image, so return a list of solutions.

    If image is invalid, inappropriate, or the problem cannot be solved, return an error message in the "error" key.
    """
    image_path = "sample2.jpg"

    response = await gemini_module.process(prompt, image_path, list[GeminiResponseSchema])
    for res in response:
        print(f"Solution: {res.solution}")
        print(f"Final Result: {res.final_result}")
        if res.error:
            print(f"Error: {res.error}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())