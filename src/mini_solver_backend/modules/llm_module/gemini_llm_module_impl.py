import json
import os

from google import genai
from pydantic import BaseModel

from .llm_module import LLMModule

class GeminiLLMModule(LLMModule):
    def __init__(self, model: str = 'gemini-2.5-flash-lite'):
        """
        Initialize the Gemini LLM module with necessary configurations.
        """
        super().__init__()
        # Load any necessary configurations or API keys here
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable is not set.")
        self.client = genai.Client(api_key=api_key)
        self.model = model

    async def process(self, prompt: str, image_path: str = None, output_schema: BaseModel = None) -> str:
        """
        Generate a response based on the provided prompt and optional image using the Gemini API.

        :param prompt: The text prompt to generate a response for.
        :param image_path: Optional path to an image to include in the response.
        :return: The generated response as a string.
        """
        try:
            file = self.client.files.upload(file=image_path)

            response = self.client.models.generate_content(
                model=self.model, 
                contents=[prompt, file],
                config={
                    "response_mime_type": "application/json",
                    "response_schema": output_schema,
                } if output_schema else None,
            )
            response_text = response.text
            results = response.parsed
            return results

        except Exception as e:
            return {"error": f"An error occurred with the Gemini API: {e}"}

