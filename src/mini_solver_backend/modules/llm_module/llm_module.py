from abc import abstractmethod

from pydantic import BaseModel

class LLMModule:
    
    @abstractmethod
    async def process(self, prompt: str, image_path: str = None, output_schema: BaseModel = None) -> str:
        """
        Generate a response based on the provided prompt and optional image.
        
        :param prompt: The text prompt to generate a response for.
        :param image_path: Optional path to an image to include in the response.
        :return: The generated response as a string.
        """
        pass
