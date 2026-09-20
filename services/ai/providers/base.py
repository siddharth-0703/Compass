from abc import ABC, abstractmethod
from typing import List, Dict, Any

class BaseProvider(ABC):
    
    @abstractmethod
    async def generate_text(self, prompt: str, **kwargs) -> str:
        """Generate text based on a prompt."""
        pass
        
    @abstractmethod
    async def generate_embedding(self, text: str, **kwargs) -> List[float]:
        """Generate a vector embedding for the given text."""
        pass
