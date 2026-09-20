from typing import List
import asyncio
import random
from .base import BaseProvider

class MockBGEProvider(BaseProvider):
    def __init__(self, dimensions: int = 384):
        self.dimensions = dimensions

    async def generate_text(self, prompt: str, **kwargs) -> str:
        raise NotImplementedError("BGE is only used for embeddings")
        
    async def generate_embedding(self, text: str, **kwargs) -> List[float]:
        # Simulate local inference time
        await asyncio.sleep(0.1)
        
        # Return a deterministic-ish vector for testing (e.g., hash the string to seed random)
        seed = sum(ord(c) for c in text)
        random.seed(seed)
        
        vector = [random.uniform(-1.0, 1.0) for _ in range(self.dimensions)]
        return vector
