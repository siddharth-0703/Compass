from typing import List
import asyncio
from .base import BaseProvider

class MockOpenAIProvider(BaseProvider):
    async def generate_text(self, prompt: str, **kwargs) -> str:
        # Simulate network latency
        await asyncio.sleep(0.5)
        return f"[Mock OpenAI Response]: I am a simulated response to: '{prompt}'"
        
    async def generate_embedding(self, text: str, **kwargs) -> List[float]:
        raise NotImplementedError("Use BGE provider for embeddings")
